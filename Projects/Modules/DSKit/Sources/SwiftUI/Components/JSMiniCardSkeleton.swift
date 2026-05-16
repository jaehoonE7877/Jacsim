import SwiftUI

public struct JSMiniCardSkeleton: View {
    public init() {}

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: JSMiniHeroCardLayout.cornerRadius)
                .skeleton(shape: RoundedRectangle(cornerRadius: JSMiniHeroCardLayout.cornerRadius))

            VStack {
                HStack {
                    Spacer()

                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 72, height: 22)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 10))
                }

                Spacer()
            }
            .padding(JSMiniHeroCardLayout.contentPadding)

            VStack(alignment: .leading, spacing: JSMiniHeroCardLayout.titleSpacing) {
                RoundedRectangle(cornerRadius: 6)
                    .frame(height: 16)
                    .skeleton(shape: RoundedRectangle(cornerRadius: 6))

                HStack(spacing: JSMiniHeroCardLayout.progressSpacing) {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(height: JSMiniHeroCardLayout.progressBarHeight)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 2))

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 30, height: 12)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(JSMiniHeroCardLayout.contentPadding)
        }
        .frame(
            width: JSMiniHeroCardLayout.size.width,
            height: JSMiniHeroCardLayout.size.height
        )
        .background(
            RoundedRectangle(cornerRadius: JSMiniHeroCardLayout.cornerRadius)
                .fill(Color.surfaceElevated)
                .jsShadow(.medium)
        )
        .clipShape(RoundedRectangle(cornerRadius: JSMiniHeroCardLayout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: JSMiniHeroCardLayout.cornerRadius)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: JSMiniHeroCardLayout.carouselSpacing) {
            JSMiniCardSkeleton()
            JSMiniCardSkeleton()
            JSMiniCardSkeleton()
        }
        .padding(.horizontal, JSMiniHeroCardLayout.carouselHorizontalPadding)
        .padding(.vertical, JSMiniHeroCardLayout.carouselVerticalPadding)
    }
    .background(Color.backgroundNormal)
}
