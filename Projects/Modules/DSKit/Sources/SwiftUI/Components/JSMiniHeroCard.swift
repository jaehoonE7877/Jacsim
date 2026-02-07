import SwiftUI

public struct JSMiniHeroCard: View {
    let title: String
    let progress: Double
    let totalDays: Int
    let completedDays: Int
    let image: Image?
    let isTodayCertified: Bool
    let onTap: () -> Void

    public init(
        title: String,
        progress: Double,
        totalDays: Int,
        completedDays: Int,
        image: Image? = nil,
        isTodayCertified: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.progress = progress
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.image = image
        self.isTodayCertified = isTodayCertified
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Full-bleed Image Background (like Hero)
                ZStack {
                    LinearGradient(
                        colors: [.primaryNormal.opacity(0.6), .primaryStrong.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(hasImage ? 0 : 1)

                    if let image = image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.18), value: hasImage)
                .frame(
                    width: JSMiniHeroCardLayout.size.width,
                    height: JSMiniHeroCardLayout.size.height
                )
                .clipped()

                // Gradient Overlay (like Hero)
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(
                    width: JSMiniHeroCardLayout.size.width,
                    height: JSMiniHeroCardLayout.size.height
                )

                VStack {
                    HStack {
                        Spacer()
                        StatusBadge(isCertified: isTodayCertified)
                    }
                    Spacer()
                }
                .padding(JSMiniHeroCardLayout.contentPadding)

                // Bottom Content (like Hero)
                VStack(alignment: .leading, spacing: JSMiniHeroCardLayout.titleSpacing) {
                    Text(title)
                        .font(.jsLabel14Bold)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // Progress bar (same style as Hero)
                    HStack(spacing: JSMiniHeroCardLayout.progressSpacing) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.white.opacity(0.25))
                                    .frame(height: JSMiniHeroCardLayout.progressBarHeight)
                                
                                Capsule()
                                    .fill(.white)
                                    .frame(
                                        width: geo.size.width * CGFloat(progress),
                                        height: JSMiniHeroCardLayout.progressBarHeight
                                    )
                            }
                        }
                        .frame(height: JSMiniHeroCardLayout.progressBarHeight)

                        Text("\(Int(progress * 100))%")
                            .font(.jsLabel11Bold)
                            .foregroundColor(.white)
                    }
                }
                .padding(JSMiniHeroCardLayout.contentPadding)
            }
            .frame(
                width: JSMiniHeroCardLayout.size.width,
                height: JSMiniHeroCardLayout.size.height
            )
            .clipShape(RoundedRectangle(cornerRadius: JSMiniHeroCardLayout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: JSMiniHeroCardLayout.cornerRadius)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .jsShadow(.medium)
        }
        .buttonStyle(PressEffectButtonStyle())
    }

    private var hasImage: Bool {
        image != nil
    }
}

private struct StatusBadge: View {
    let isCertified: Bool

    var body: some View {
        Text(isCertified ? "오늘 인증 완료" : "오늘 미인증")
            .font(.jsLabel10Bold)
            .foregroundColor(isCertified ? .green : .white)
            .padding(.horizontal, JSMiniHeroCardLayout.badgeHorizontalPadding)
            .padding(.vertical, JSMiniHeroCardLayout.badgeVerticalPadding)
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

public struct JSMiniHeroCardCarousel: View {
    let cards: [JSMiniHeroCardData]
    let onCardTap: (UUID) -> Void

    public init(
        cards: [JSMiniHeroCardData],
        onCardTap: @escaping (UUID) -> Void
    ) {
        self.cards = cards
        self.onCardTap = onCardTap
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: JSMiniHeroCardLayout.carouselSpacing) {
                ForEach(cards) { card in
                    JSMiniHeroCard(
                        title: card.title,
                        progress: card.progress,
                        totalDays: card.totalDays,
                        completedDays: card.completedDays,
                        image: card.image,
                        isTodayCertified: card.isTodayCertified,
                        onTap: { onCardTap(card.id) }
                    )
                }
            }
            .padding(.horizontal, JSMiniHeroCardLayout.carouselHorizontalPadding)
            .padding(.vertical, JSMiniHeroCardLayout.carouselVerticalPadding)
        }
        .frame(height: JSMiniHeroCardLayout.size.height)
        .scrollClipDisabled(false)
    }
}

public struct JSMiniHeroCardData: Identifiable {
    public let id: UUID
    public let title: String
    public let progress: Double
    public let totalDays: Int
    public let completedDays: Int
    public let image: Image?
    public let isTodayCertified: Bool

    public init(
        id: UUID,
        title: String,
        progress: Double,
        totalDays: Int,
        completedDays: Int,
        image: Image? = nil,
        isTodayCertified: Bool = false
    ) {
        self.id = id
        self.title = title
        self.progress = progress
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.image = image
        self.isTodayCertified = isTodayCertified
    }
}

struct JSMiniHeroCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Mini Hero Cards")
                    .font(.jsHeadline18Bold)

                JSMiniHeroCard(
                    title: "두쫀쿠",
                    progress: 0.4,
                    totalDays: 15,
                    completedDays: 0,
                    onTap: {}
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                JSMiniHeroCard(
                    title: "hhh",
                    progress: 0.65,
                    totalDays: 18,
                    completedDays: 0,
                    onTap: {}
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Text("Carousel")
                    .font(.jsHeadline18Bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)

                JSMiniHeroCardCarousel(
                    cards: [
                        JSMiniHeroCardData(
                            id: UUID(),
                            title: "두쫀쿠",
                            progress: 0.4,
                            totalDays: 15,
                            completedDays: 0
                        ),
                        JSMiniHeroCardData(
                            id: UUID(),
                            title: "hhh",
                            progress: 0.65,
                            totalDays: 18,
                            completedDays: 0
                        ),
                        JSMiniHeroCardData(
                            id: UUID(),
                            title: "물 마시기",
                            progress: 0.85,
                            totalDays: 30,
                            completedDays: 25
                        )
                    ],
                    onCardTap: { id in
                        print("Tapped card id: \(id)")
                    }
                )
            }
            .padding(.vertical)
        }
        .background(Color.backgroundNormal)
    }
}
