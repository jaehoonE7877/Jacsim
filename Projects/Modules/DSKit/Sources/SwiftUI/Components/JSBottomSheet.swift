import SwiftUI

public enum JSBottomSheetStyle {
    case fixed(height: CGFloat)
    case flexible(maxHeight: CGFloat)
    case contentHeight
}

public struct JSBottomSheet<Content: View>: View {
    let isPresented: Binding<Bool>
    let style: JSBottomSheetStyle
    let showDragIndicator: Bool
    let content: Content
    let onDismiss: (() -> Void)?

    @State private var offset: CGFloat = 0
    @State private var isDragging = false

    public init(
        isPresented: Binding<Bool>,
        style: JSBottomSheetStyle = .flexible(maxHeight: 400),
        showDragIndicator: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented
        self.style = style
        self.showDragIndicator = showDragIndicator
        self.onDismiss = onDismiss
        self.content = content()
    }

    public var body: some View {
        ZStack {
            if isPresented.wrappedValue {
                Color.black
                    .opacity(0.4 * max(0, 1 - abs(offset) / 300.0))
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
                    .transition(.opacity)

                VStack(spacing: 0) {
                    if showDragIndicator {
                        dragIndicator
                    }

                    content
                        .frame(maxWidth: .infinity)
                        .frame(height: sheetHeight)
                }
                .background(
                    Color(.systemBackground)
                        .jsCornerRadius(16, corners: [.topLeft, .topRight])
                )
                .offset(y: max(0, offset))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            if value.translation.height > 0 {
                                offset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            isDragging = false
                            let threshold: CGFloat = 100
                            if value.translation.height > threshold {
                                dismiss()
                            } else {
                                withAnimation(.spring()) {
                                    offset = 0
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented.wrappedValue)
    }

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color.gray.opacity(0.4))
            .frame(width: 36, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    private var sheetHeight: CGFloat? {
        switch style {
        case .fixed(let height):
            return height
        case .flexible:
            return nil
        case .contentHeight:
            return nil
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = 0
            isPresented.wrappedValue = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss?()
        }
    }
}

extension View {
    func jsCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(JSRoundedCorner(radius: radius, corners: corners))
    }
}

struct JSRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

public struct JSDatePickerBottomSheet: View {
    @Binding var selectedDate: Date
    let isPresented: Binding<Bool>
    let title: String
    let onConfirm: (() -> Void)?
    let onDismiss: (() -> Void)?

    public init(
        selectedDate: Binding<Date>,
        isPresented: Binding<Bool>,
        title: String = "날짜 선택",
        onConfirm: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self._selectedDate = selectedDate
        self.isPresented = isPresented
        self.title = title
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
    }

    public var body: some View {
        JSBottomSheet(
            isPresented: isPresented,
            style: .fixed(height: 420),
            onDismiss: onDismiss
        ) {
            VStack(spacing: 0) {
                header

                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 16)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: {
                        isPresented.wrappedValue = false
                        onDismiss?()
                    }) {
                        Text("취소")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.2))
                            )
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())

                    Button(action: {
                        isPresented.wrappedValue = false
                        onConfirm?()
                    }) {
                        Text("확인")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                }
                .padding(16)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()

            Button(action: {
                isPresented.wrappedValue = false
                onDismiss?()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct JSBottomSheet_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var showSheet = false
        @State private var selectedDate = Date()

        var body: some View {
            ZStack {
                VStack {
                    Button(action: { showSheet = true }) {
                        Text("Show Bottom Sheet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                    }
                    .padding()

                    Spacer()
                }

                JSDatePickerBottomSheet(
                    selectedDate: $selectedDate,
                    isPresented: $showSheet,
                    title: "날짜 선택",
                    onConfirm: {
                        print("Selected: \(selectedDate)")
                    }
                )
            }
        }
    }

    static var previews: some View {
        PreviewContainer()
    }
}
