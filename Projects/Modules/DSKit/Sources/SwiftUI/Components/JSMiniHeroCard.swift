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
                Group {
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
                .frame(width: 160, height: 200)
                .clipped()

                // Gradient Overlay (like Hero)
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 160, height: 200)

                VStack {
                    HStack {
                        Spacer()
                        StatusBadge(isCertified: isTodayCertified)
                    }
                    Spacer()
                }
                .padding(12)

                // Bottom Content (like Hero)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // Progress bar (same style as Hero)
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: geo.size.width * CGFloat(progress), height: 4)
                            }
                        }
                        .frame(height: 4)

                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(12)
            }
            .frame(width: 160, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(
                color: .black.opacity(0.15),
                radius: 16,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(PlainButtonStyle())
        .pressEffect()
    }
}

private struct StatusBadge: View {
    let isCertified: Bool

    var body: some View {
        Text(isCertified ? "오늘 인증 완료" : "오늘 미인증")
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(isCertified ? .green : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(isCertified ? Color.green.opacity(0.3) : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

public struct JSMiniHeroCardCarousel: View {
    let cards: [JSMiniHeroCardData]
    let onCardTap: (Int) -> Void

    public init(
        cards: [JSMiniHeroCardData],
        onCardTap: @escaping (Int) -> Void
    ) {
        self.cards = cards
        self.onCardTap = onCardTap
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                    JSMiniHeroCard(
                        title: card.title,
                        progress: card.progress,
                        totalDays: card.totalDays,
                        completedDays: card.completedDays,
                        image: card.image,
                        isTodayCertified: card.isTodayCertified,
                        onTap: { onCardTap(index) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
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
                    .font(.system(size: 18, weight: .semibold))

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
                    .font(.system(size: 18, weight: .semibold))
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
                    onCardTap: { index in
                        print("Tapped card at index: \(index)")
                    }
                )
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}
