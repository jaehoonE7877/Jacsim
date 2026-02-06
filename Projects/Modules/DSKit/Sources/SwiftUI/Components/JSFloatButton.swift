import SwiftUI

public struct JSFloatButtonItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let icon: Image
    public let action: () -> Void

    public init(title: String, icon: Image, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}

public struct JSFloatButton: View {
    private let items: [JSFloatButtonItem]
    @State private var isExpanded = false

    public init(items: [JSFloatButtonItem]) {
        self.items = items
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isExpanded {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }
                    .transition(.opacity)

                VStack(alignment: .trailing, spacing: 16) {
                    ForEach(items) { item in
                        HStack(spacing: 12) {
                            Text(item.title)
                                .font(.pretendardSemiBold(size: 14))
                                .foregroundColor(.labelStrong)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.backgroundNormal)
                                        .shadow(
                                            color: Color.black.opacity(0.08),
                                            radius: 6, x: 0, y: 3
                                        )
                                )

                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isExpanded = false
                                }
                                item.action()
                            }) {
                                item.icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .padding(14)
                                    .background(
                                        Circle()
                                            .fill(Color.primaryNormal)
                                            .shadow(
                                                color: Color.primaryNormal.opacity(0.35),
                                                radius: 10, x: 0, y: 5
                                            )
                                    )
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.bottom, 88)
                .padding(.trailing, 16)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8, anchor: .bottomTrailing).combined(with: .opacity),
                    removal: .scale(scale: 0.9, anchor: .bottomTrailing).combined(with: .opacity)
                ))
            }

            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(18)
                    .background(
                        Circle()
                            .fill(Color.primaryNormal)
                            .shadow(
                                color: Color.primaryNormal.opacity(0.4),
                                radius: 12, x: 0, y: 6
                            )
                    )
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
    }
}
