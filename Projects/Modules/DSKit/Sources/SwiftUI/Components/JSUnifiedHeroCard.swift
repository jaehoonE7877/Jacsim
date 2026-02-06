import SwiftUI

public struct JSUnifiedHeroCard: View {
    let title: String
    let subtitle: String?
    let progress: Double
    let totalDays: Int
    let completedDays: Int
    let image: Image?
    let isTodayCertified: Bool
    let onTap: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        progress: Double,
        totalDays: Int,
        completedDays: Int,
        image: Image? = nil,
        isTodayCertified: Bool,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.image = image
        self.isTodayCertified = isTodayCertified
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            GeometryReader { proxy in
                let cardSize = proxy.size

                RoundedRectangle(cornerRadius: JSHeroCardLayout.cornerRadius)
                    .fill(Color.surfaceElevated)
                    .overlay {
                        ZStack(alignment: .bottomLeading) {
                            if let image = image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: cardSize.width, height: cardSize.height)
                                    .clipped()
                            } else {
                                LinearGradient(
                                    colors: [.primaryNormal.opacity(0.6), .primaryStrong.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: cardSize.width, height: cardSize.height)
                            }

                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(width: cardSize.width, height: cardSize.height)

                            VStack(alignment: .leading, spacing: JSHeroCardLayout.contentSpacing) {
                                HStack {
                                    Spacer()
                                    StatusBadge(isCertified: isTodayCertified)
                                }

                                Spacer()

                                VStack(alignment: .leading, spacing: JSHeroCardLayout.detailSpacing) {
                                    Text(title)
                                        .font(.jsDisplay26Bold)
                                        .foregroundColor(.white)
                                        .lineLimit(2)

                                    if let subtitle = subtitle {
                                        Text(subtitle)
                                            .font(.jsBody15Medium)
                                            .foregroundColor(.white.opacity(0.85))
                                            .lineLimit(1)
                                    }

                                    // Unified Progress Bar
                                    HStack(spacing: JSHeroCardLayout.progressSpacing) {
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(.white.opacity(0.25))
                                                    .frame(height: JSHeroCardLayout.progressBarHeight)

                                                Capsule()
                                                    .fill(.white)
                                                    .frame(
                                                        width: geo.size.width * CGFloat(progress),
                                                        height: JSHeroCardLayout.progressBarHeight
                                                    )
                                            }
                                        }
                                        .frame(height: JSHeroCardLayout.progressBarHeight)

                                        Text("\(Int(progress * 100))%")
                                            .font(.jsLabel13Bold)
                                            .foregroundColor(.white)
                                            .frame(
                                                minWidth: JSHeroCardLayout.progressTextMinWidth,
                                                alignment: .trailing
                                            )
                                    }
                                    .padding(.top, JSHeroCardLayout.progressTopPadding)
                                }
                            }
                            .padding(JSHeroCardLayout.contentPadding)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: JSHeroCardLayout.cornerRadius))
                    }
            }
            .frame(maxWidth: .infinity)
            .frame(height: JSHeroCardLayout.height)
            .jsShadow(.medium)
        }
        .buttonStyle(PressEffectButtonStyle())
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: JSHeroCardLayout.cornerRadius))
    }
}

private struct StatusBadge: View {
    let isCertified: Bool
    
    var body: some View {
        Text(isCertified ? "오늘 인증 완료" : "오늘 미인증")
            .font(.jsLabel12Bold)
            .foregroundColor(isCertified ? .green : .white)
            .padding(.horizontal, JSHeroCardLayout.badgeHorizontalPadding)
            .padding(.vertical, JSHeroCardLayout.badgeVerticalPadding)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(isCertified ? .green.opacity(0.3) : .white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

struct JSUnifiedHeroCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                JSUnifiedHeroCard(
                    title: "매일 아침 6시 기상하기",
                    subtitle: "성공적인 하루를 위한 시작",
                    progress: 0.7,
                    totalDays: 30,
                    completedDays: 21,
                    isTodayCertified: false,
                    onTap: {}
                )
                .padding()

                JSUnifiedHeroCard(
                    title: "물 2L 마시기",
                    progress: 0.3,
                    totalDays: 7,
                    completedDays: 2,
                    isTodayCertified: true,
                    onTap: {}
                )
                .padding()
            }
        }
        .background(Color.backgroundAlternative)
    }
}
