import SwiftUI

public struct JSMiniCardSkeleton: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(height: 80)
                    .skeleton(cornerRadius: 4)

                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 36, height: 16)
                    .padding(6)
                    .skeleton(cornerRadius: 10)
            }

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .frame(height: 16)
                    .skeleton(cornerRadius: 6)

                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 3)
                    .skeleton(cornerRadius: 2)
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
            JSMiniCardSkeleton()
            JSMiniCardSkeleton()
            JSMiniCardSkeleton()
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
