import SwiftUI

public struct JSHeroCardSkeleton: View {
    public init() {}

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: JSHeroCardLayout.cornerRadius)
                .skeleton(shape: RoundedRectangle(cornerRadius: JSHeroCardLayout.cornerRadius))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(alignment: .leading, spacing: JSHeroCardLayout.contentSpacing) {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 96, height: 24)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                VStack(alignment: .leading, spacing: JSHeroCardLayout.detailSpacing) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(height: 28)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 8))

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 160, height: 16)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 6))

                    HStack(spacing: JSHeroCardLayout.progressSpacing) {
                        RoundedRectangle(cornerRadius: 3)
                            .frame(height: JSHeroCardLayout.progressBarHeight)
                            .skeleton(shape: RoundedRectangle(cornerRadius: 3))

                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: JSHeroCardLayout.progressTextMinWidth, height: 14)
                            .skeleton(shape: RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.top, JSHeroCardLayout.progressTopPadding)
                }
            }
            .padding(JSHeroCardLayout.contentPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: JSHeroCardLayout.height)
        .background(
            RoundedRectangle(cornerRadius: JSHeroCardLayout.cornerRadius)
                .fill(Color.skeletonContainer)
                .jsShadow(.medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
}

#Preview {
    JSHeroCardSkeleton()
        .padding()
        .background(Color.backgroundNormal)
}
