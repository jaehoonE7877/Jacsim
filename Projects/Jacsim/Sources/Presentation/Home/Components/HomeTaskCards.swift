import SwiftUI
import DesignSystem

struct HomeHeroCard: View {
    let title: String
    let subtitle: String?
    let progress: Double
    let totalDays: Int
    let completedDays: Int
    let image: Image?
    let isTodayCertified: Bool
    let accessibilityLabel: String?
    let accessibilityHint: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GeometryReader { proxy in
                let cardSize = proxy.size

                RoundedRectangle(cornerRadius: HomeHeroCardLayout.cornerRadius)
                    .fill(Color.surfaceElevated)
                    .overlay {
                        ZStack(alignment: .bottomLeading) {
                            if let image {
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

                            VStack(alignment: .leading, spacing: HomeHeroCardLayout.contentSpacing) {
                                HStack {
                                    Spacer()
                                    HomeCertificationBadge(
                                        isCertified: isTodayCertified,
                                        font: .jsLabelSmall,
                                        horizontalPadding: HomeHeroCardLayout.badgeHorizontalPadding,
                                        verticalPadding: HomeHeroCardLayout.badgeVerticalPadding
                                    )
                                }

                                Spacer()

                                VStack(alignment: .leading, spacing: HomeHeroCardLayout.detailSpacing) {
                                    Text(title)
                                        .font(.jsDisplaySmall)
                                        .foregroundColor(.white)
                                        .lineLimit(2)

                                    if let subtitle {
                                        Text(subtitle)
                                            .font(.jsBodySmall)
                                            .foregroundColor(.white.opacity(0.85))
                                            .lineLimit(1)
                                    }

                                    HStack(spacing: HomeHeroCardLayout.progressSpacing) {
                                        GeometryReader { geo in
                                            ZStack(alignment: .leading) {
                                                Capsule()
                                                    .fill(.white.opacity(0.25))
                                                    .frame(height: HomeHeroCardLayout.progressBarHeight)

                                                Capsule()
                                                    .fill(.white)
                                                    .frame(
                                                        width: geo.size.width * CGFloat(progress),
                                                        height: HomeHeroCardLayout.progressBarHeight
                                                    )
                                            }
                                        }
                                        .frame(height: HomeHeroCardLayout.progressBarHeight)

                                        Text("\(Int(progress * 100))%")
                                            .font(.jsLabelSmall)
                                            .foregroundColor(.white)
                                            .frame(
                                                minWidth: HomeHeroCardLayout.progressTextMinWidth,
                                                alignment: .trailing
                                            )
                                    }
                                    .padding(.top, HomeHeroCardLayout.progressTopPadding)
                                }
                            }
                            .padding(HomeHeroCardLayout.contentPadding)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: HomeHeroCardLayout.cornerRadius))
                    }
            }
            .frame(maxWidth: .infinity)
            .frame(height: HomeHeroCardLayout.height)
            .jsShadow(.medium)
        }
        .buttonStyle(HomeCardPressButtonStyle())
        .frame(maxWidth: .infinity)
        .contentShape(RoundedRectangle(cornerRadius: HomeHeroCardLayout.cornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? defaultAccessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "작심 상세 화면으로 이동합니다")
    }

    private var defaultAccessibilityLabel: String {
        let progressText = "진행률 \(Int(progress * 100))퍼센트"
        let completionText = "\(completedDays)/\(max(totalDays, 1))일 완료"
        return "\(title), \(progressText), \(completionText)"
    }
}

struct HomeMiniHeroCardCarousel: View {
    let cards: [HomeMiniHeroCardData]
    let onCardTap: (UUID) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: HomeMiniHeroCardLayout.carouselSpacing) {
                ForEach(cards) { card in
                    HomeMiniHeroCard(
                        title: card.title,
                        progress: card.progress,
                        totalDays: card.totalDays,
                        completedDays: card.completedDays,
                        image: card.image,
                        isTodayCertified: card.isTodayCertified,
                        accessibilityLabel: card.accessibilityLabel,
                        accessibilityHint: card.accessibilityHint,
                        onTap: { onCardTap(card.id) }
                    )
                    .frame(width: HomeMiniHeroCardLayout.size.width)
                }
            }
            .padding(.horizontal, HomeMiniHeroCardLayout.carouselHorizontalPadding)
            .padding(.vertical, HomeMiniHeroCardLayout.carouselVerticalPadding)
        }
        .frame(height: HomeMiniHeroCardLayout.size.height)
        .scrollClipDisabled(false)
    }
}

struct HomeMiniHeroCardData: Identifiable {
    let id: UUID
    let title: String
    let progress: Double
    let totalDays: Int
    let completedDays: Int
    let image: Image?
    let isTodayCertified: Bool
    let accessibilityLabel: String?
    let accessibilityHint: String?
}

private struct HomeMiniHeroCard: View {
    let title: String
    let progress: Double
    let totalDays: Int
    let completedDays: Int
    let image: Image?
    let isTodayCertified: Bool
    let accessibilityLabel: String?
    let accessibilityHint: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                ZStack {
                    LinearGradient(
                        colors: [.primaryNormal.opacity(0.6), .primaryStrong.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(image == nil ? 1 : 0)

                    if let image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                    }
                }
                .animation(JSAnimation.toast, value: image != nil)
                .frame(
                    width: HomeMiniHeroCardLayout.size.width,
                    height: HomeMiniHeroCardLayout.size.height
                )
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(
                    width: HomeMiniHeroCardLayout.size.width,
                    height: HomeMiniHeroCardLayout.size.height
                )

                VStack {
                    HStack {
                        Spacer()
                        HomeCertificationBadge(
                            isCertified: isTodayCertified,
                            font: .jsLabelSmall,
                            horizontalPadding: HomeMiniHeroCardLayout.badgeHorizontalPadding,
                            verticalPadding: HomeMiniHeroCardLayout.badgeVerticalPadding
                        )
                    }
                    Spacer()
                }
                .padding(HomeMiniHeroCardLayout.contentPadding)

                VStack(alignment: .leading, spacing: HomeMiniHeroCardLayout.titleSpacing) {
                    Text(title)
                        .font(.jsBodySmall)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: HomeMiniHeroCardLayout.progressSpacing) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.white.opacity(0.25))
                                    .frame(height: HomeMiniHeroCardLayout.progressBarHeight)

                                Capsule()
                                    .fill(.white)
                                    .frame(
                                        width: geo.size.width * CGFloat(progress),
                                        height: HomeMiniHeroCardLayout.progressBarHeight
                                    )
                            }
                        }
                        .frame(height: HomeMiniHeroCardLayout.progressBarHeight)

                        Text("\(Int(progress * 100))%")
                            .font(.jsLabelSmall)
                            .foregroundColor(.white)
                    }
                }
                .padding(HomeMiniHeroCardLayout.contentPadding)
            }
            .frame(
                width: HomeMiniHeroCardLayout.size.width,
                height: HomeMiniHeroCardLayout.size.height
            )
            .clipShape(RoundedRectangle(cornerRadius: HomeMiniHeroCardLayout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: HomeMiniHeroCardLayout.cornerRadius)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .jsShadow(.medium)
        }
        .buttonStyle(HomeCardPressButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? defaultAccessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "작심 상세 화면으로 이동합니다")
    }

    private var defaultAccessibilityLabel: String {
        let progressText = "진행률 \(Int(progress * 100))퍼센트"
        let completionText = "\(completedDays)/\(max(totalDays, 1))일 완료"
        return "\(title), \(progressText), \(completionText)"
    }
}

private struct HomeCertificationBadge: View {
    let isCertified: Bool
    let font: Font
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat

    var body: some View {
        Text(isCertified ? "오늘 완료" : "인증 필요")
            .font(font)
            .foregroundColor(isCertified ? .green : .white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
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

private struct HomeCardPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(JSAnimation.toast, value: configuration.isPressed)
    }
}

private enum HomeHeroCardLayout {
    static var height: CGFloat { 320.jsScaled() }
    static var cornerRadius: CGFloat { 20.jsScaled() }
    static var contentPadding: CGFloat { 20.jsScaled() }
    static var contentSpacing: CGFloat { 14.jsScaled() }
    static var detailSpacing: CGFloat { 6.jsScaled() }
    static var progressSpacing: CGFloat { 10.jsScaled() }
    static var progressBarHeight: CGFloat { 6.jsScaled() }
    static var progressTextMinWidth: CGFloat { 50.jsScaled() }
    static var progressTopPadding: CGFloat { 6.jsScaled() }
    static var badgeHorizontalPadding: CGFloat { 10.jsScaled() }
    static var badgeVerticalPadding: CGFloat { 5.jsScaled() }
}

private enum HomeMiniHeroCardLayout {
    static var size: CGSize { CGSize(width: 160, height: 200).jsScaled() }
    static var cornerRadius: CGFloat { 20.jsScaled() }
    static var contentPadding: CGFloat { 14.jsScaled() }
    static var titleSpacing: CGFloat { 4.jsScaled() }
    static var progressSpacing: CGFloat { 8.jsScaled() }
    static var progressBarHeight: CGFloat { 4.jsScaled() }
    static var badgeHorizontalPadding: CGFloat { 8.jsScaled() }
    static var badgeVerticalPadding: CGFloat { 4.jsScaled() }
    static var carouselSpacing: CGFloat { 12.jsScaled() }
    static var carouselHorizontalPadding: CGFloat { 20.jsScaled() }
    static var carouselVerticalPadding: CGFloat { 4.jsScaled() }
}
