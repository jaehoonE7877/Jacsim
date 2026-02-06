import SwiftUI

public enum JSModalStyle {
    case bottomSheet
    case centerAlert
}

public struct JSModalButton {
    let title: String
    let style: JSModalButtonStyle
    let dismissOnTap: Bool
    let action: () -> Void

    public init(
        title: String,
        style: JSModalButtonStyle = .primary,
        dismissOnTap: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.dismissOnTap = dismissOnTap
        self.action = action
    }
}

public enum JSModalButtonStyle {
    case primary
    case secondary
}

public struct JSModal<Content: View>: View {
    let isPresented: Binding<Bool>
    let style: JSModalStyle
    let title: String?
    let content: Content
    let primaryButton: JSModalButton?
    let secondaryButton: JSModalButton?

    public init(
        isPresented: Binding<Bool>,
        style: JSModalStyle = .bottomSheet,
        title: String? = nil,
        primaryButton: JSModalButton? = nil,
        secondaryButton: JSModalButton? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.isPresented = isPresented
        self.style = style
        self.title = title
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.content = content()
    }

    public var body: some View {
        ZStack {
            if isPresented.wrappedValue {
                overlay
                    .transition(.opacity)

                modalContainer
                    .transition(modalTransition)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented.wrappedValue)
    }

    private var overlay: some View {
        Color.black
            .opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture {
                if style == .bottomSheet {
                    isPresented.wrappedValue = false
                }
            }
    }

    private var modalContainer: some View {
        Group {
            switch style {
            case .bottomSheet:
                bottomSheetContent
            case .centerAlert:
                centerAlertContent
            }
        }
    }

    private var bottomSheetContent: some View {
        VStack(spacing: 0) {
            dragIndicator

            if let title = title {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
            }

            content
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            buttonStack
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private var centerAlertContent: some View {
        VStack(spacing: 20) {
            if let title = title {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }

            content

            buttonStack
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black
                .opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture { }
        )
    }

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color.gray.opacity(0.5))
            .frame(width: 36, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }

    @ViewBuilder
    private var buttonStack: some View {
        if primaryButton != nil || secondaryButton != nil {
            VStack(spacing: 8) {
                if let primary = primaryButton {
                    Button(action: {
                        primary.action()
                        if primary.dismissOnTap {
                            isPresented.wrappedValue = false
                        }
                    }) {
                        Text(primary.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }

                if let secondary = secondaryButton {
                    Button(action: {
                        secondary.action()
                        if secondary.dismissOnTap {
                            isPresented.wrappedValue = false
                        }
                    }) {
                        Text(secondary.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                }
            }
        }
    }

    private var modalTransition: AnyTransition {
        switch style {
        case .bottomSheet:
            return .move(edge: .bottom)
        case .centerAlert:
            return .scale(scale: 0.9)
                .combined(with: .opacity)
        }
    }
}

struct RoundedCorner: Shape {
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct JSModal_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var showBottomSheet = false
        @State private var showAlert = false

        var body: some View {
            VStack(spacing: 20) {
                Button("Show Bottom Sheet") {
                    showBottomSheet = true
                }

                Button("Show Alert") {
                    showAlert = true
                }
            }
            .padding()
            .jsModal(
                isPresented: $showBottomSheet,
                style: .bottomSheet,
                title: "Options",
                primaryButton: JSModalButton(title: "Confirm") {},
                secondaryButton: JSModalButton(title: "Cancel", style: .secondary) {}
            ) {
                VStack(spacing: 12) {
                    Text("Option 1")
                    Text("Option 2")
                    Text("Option 3")
                }
            }
            .jsModal(
                isPresented: $showAlert,
                style: .centerAlert,
                title: "Delete Task?",
                primaryButton: JSModalButton(title: "Delete", style: .primary) {},
                secondaryButton: JSModalButton(title: "Cancel", style: .secondary) {}
            ) {
                Text("This action cannot be undone.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    static var previews: some View {
        PreviewContainer()
    }
}

extension View {
    public func jsModal<Content: View>(
        isPresented: Binding<Bool>,
        style: JSModalStyle = .bottomSheet,
        title: String? = nil,
        primaryButton: JSModalButton? = nil,
        secondaryButton: JSModalButton? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            self

            JSModal(
                isPresented: isPresented,
                style: style,
                title: title,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton,
                content: content
            )
        }
    }
}
