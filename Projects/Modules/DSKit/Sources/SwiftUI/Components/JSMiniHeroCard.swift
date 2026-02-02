import SwiftUI

public struct JSMiniHeroCard: View {
    let title: String
    let progress: Double
    let totalDays: Int
    let completedDays: Int
    let image: Image?
    let onTap: () -> Void

    public init(
        title: String,
        progress: Double,
        totalDays: Int,
        completedDays: Int,
        image: Image? = nil,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.progress = progress
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.image = image
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

                // Top-right badge
                VStack {
                    HStack {
                        Spacer()
                        Text("\(completedDays)/\(totalDays)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
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
    public let id = UUID()
    public let title: String
    public let progress: Double
    public let totalDays: Int
    public let completedDays: Int
    public let image: Image?

    public init(
        title: String,
        progress: Double,
        totalDays: Int,
        completedDays: Int,
        image: Image? = nil
    ) {
        self.title = title
        self.progress = progress
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.image = image
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
                            title: "두쫀쿠",
                            progress: 0.4,
                            totalDays: 15,
                            completedDays: 0
                        ),
                        JSMiniHeroCardData(
                            title: "hhh",
                            progress: 0.65,
                            totalDays: 18,
                            completedDays: 0
                        ),
                        JSMiniHeroCardData(
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
