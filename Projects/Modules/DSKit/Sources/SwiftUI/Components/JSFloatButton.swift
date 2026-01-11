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
                Color.black.opacity(0.001)
                    .onTapGesture {
                        withAnimation { isExpanded = false }
                    }
                
                VStack(alignment: .trailing, spacing: 16) {
                    ForEach(items) { item in
                        HStack(spacing: 12) {
                            Text(item.title)
                                .font(.pretendardMedium(size: 14))
                                .foregroundColor(.labelNormal)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.backgroundNormal)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                            
                            Button(action: {
                                withAnimation { isExpanded = false }
                                item.action()
                            }) {
                                item.icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding(12)
                                    .background(Color.primaryNormal)
                                    .foregroundColor(.labelNormal)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                        }
                    }
                }
                .padding(.bottom, 80)
                .padding(.trailing, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(16)
                    .background(Color.primaryNormal)
                    .foregroundColor(.labelNormal)
                    .clipShape(Circle())
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                    .shadow(radius: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
    }
}
