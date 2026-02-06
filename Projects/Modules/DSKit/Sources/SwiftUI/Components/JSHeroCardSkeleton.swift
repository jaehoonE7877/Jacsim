import SwiftUI

public struct JSHeroCardSkeleton: View {
    public init() {}

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24)
                .skeleton(shape: RoundedRectangle(cornerRadius: 24))

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 96, height: 24)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 12))
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(height: 28)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 8))

                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 160, height: 16)
                        .skeleton(shape: RoundedRectangle(cornerRadius: 6))

                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 3)
                            .frame(height: 6)
                            .skeleton(shape: RoundedRectangle(cornerRadius: 3))

                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 60, height: 14)
                            .skeleton(shape: RoundedRectangle(cornerRadius: 6))
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
        }
        .frame(height: 320)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.surfaceElevated)
                .jsShadow(.medium)
        )
    }
}

#Preview {
    JSHeroCardSkeleton()
        .padding()
        .background(Color.backgroundNormal)
}
