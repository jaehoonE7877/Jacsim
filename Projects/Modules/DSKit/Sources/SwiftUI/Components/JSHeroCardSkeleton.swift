import SwiftUI

public struct JSHeroCardSkeleton: View {
    @State private var opacity: Double = 0.6
    
    public init() {}

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.12))
                .animatedSkeleton(cornerRadius: 24)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 96, height: 24)
                        .animatedSkeleton(cornerRadius: 12)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(height: 28)
                        .animatedSkeleton(cornerRadius: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 160, height: 16)
                        .animatedSkeleton(cornerRadius: 6)

                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 3)
                            .frame(height: 6)
                            .animatedSkeleton(cornerRadius: 3)

                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 60, height: 14)
                            .animatedSkeleton(cornerRadius: 6)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
        }
        .frame(height: 320)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    JSHeroCardSkeleton()
        .padding()
        .background(Color.gray.opacity(0.1))
}
