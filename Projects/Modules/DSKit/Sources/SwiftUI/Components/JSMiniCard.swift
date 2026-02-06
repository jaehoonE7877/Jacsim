import SwiftUI

public struct JSMiniCard: View {
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
            VStack(alignment: .leading, spacing: 12) {
                imageSection
                contentSection
            }
            .padding(12)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.surfaceElevated)
                    .jsShadow(.small)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
        .pressEffect()
    }

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .primaryNormal.opacity(0.6),
                                    .primaryStrong.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            Text("\(completedDays)/\(totalDays)")
                .font(.pretendardBold(size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.surfaceOverlay.opacity(0.4))
                )
                .padding(6)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.pretendardMedium(size: 15))
                .foregroundColor(Color.labelNormal)
                .lineLimit(1)

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryNormal))
                .frame(height: 3)
        }
    }
}

public struct JSMiniCardCarousel: View {
    let cards: [JSMiniCardData]
    let onCardTap: (Int) -> Void

    public init(
        cards: [JSMiniCardData],
        onCardTap: @escaping (Int) -> Void
    ) {
        self.cards = cards
        self.onCardTap = onCardTap
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                    JSMiniCard(
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

public struct JSMiniCardData: Identifiable {
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

struct JSMiniCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Single MiniCard")
                    .font(.pretendardBold(size: 18))

                JSMiniCard(
                    title: "물 마시기",
                    progress: 0.4,
                    totalDays: 7,
                    completedDays: 2,
                    onTap: {}
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("Carousel")
                    .font(.pretendardBold(size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)

                JSMiniCardCarousel(
                    cards: [
                        JSMiniCardData(
                            title: "독서하기",
                            progress: 0.65,
                            totalDays: 30,
                            completedDays: 19
                        ),
                        JSMiniCardData(
                            title: "물 마시기",
                            progress: 0.4,
                            totalDays: 7,
                            completedDays: 2
                        ),
                        JSMiniCardData(
                            title: "울기",
                            progress: 0.85,
                            totalDays: 15,
                            completedDays: 12
                        ),
                        JSMiniCardData(
                            title: "일기쓰기",
                            progress: 0.2,
                            totalDays: 30,
                            completedDays: 6
                        )
                    ],
                    onCardTap: { index in
                        print("Tapped card at index: \(index)")
                    }
                )
                .padding(.horizontal, -20)
            }
            .padding()
        }
        .background(Color.backgroundNormal)
    }
}
