import SwiftUI

public struct JSHeroCard: View {
    let title: String
    let subtitle: String?
    let progress: Double
    let totalDays: Int
    let completedDays: Int
    let image: Image?
    let onTap: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        progress: Double,
        totalDays: Int,
        completedDays: Int,
        image: Image? = nil,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
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
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DSKitAsset.Colors.surfacePrimary.swiftUIColor)
                    .jsShadow(.medium)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }

    private var imageSection: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DSKitAsset.Colors.primaryNormal.swiftUIColor.opacity(0.8),
                                    DSKitAsset.Colors.primaryNormal.swiftUIColor
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            LinearGradient(
                colors: [.clear, DSKitAsset.Colors.dim.swiftUIColor.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
            .clipShape(
                RoundedRectangle(cornerRadius: 8)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("\(completedDays)/\(totalDays)일")
                    .font(.jsLabel12Bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                    )
            }
            .padding(12)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.jsHeadline18Bold)
                .foregroundColor(DSKitAsset.Colors.textPrimary.swiftUIColor)
                .lineLimit(1)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.jsBody14Regular)
                    .foregroundColor(DSKitAsset.Colors.textSecondary.swiftUIColor)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: DSKitAsset.Colors.primaryNormal.swiftUIColor))
                    .frame(height: 4)

                Text("\(Int(progress * 100))%")
                    .font(.jsLabel12Bold)
                    .foregroundColor(DSKitAsset.Colors.primaryNormal.swiftUIColor)
                    .frame(width: 36, alignment: .trailing)
            }
            .padding(.top, 4)
        }
    }
}

struct JSHeroCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                JSHeroCard(
                    title: "매일 30분 독서하기",
                    subtitle: "아침 시간을 활용해서 책 읽기",
                    progress: 0.65,
                    totalDays: 30,
                    completedDays: 19,
                    onTap: {}
                )

                JSHeroCard(
                    title: "물 2L 마시기",
                    subtitle: "건강한 습관 만들기",
                    progress: 0.4,
                    totalDays: 7,
                    completedDays: 2,
                    image: Image(systemName: "drop.fill"),
                    onTap: {}
                )

                JSHeroCard(
                    title: "매일 운전 연습",
                    progress: 0.85,
                    totalDays: 15,
                    completedDays: 12,
                    onTap: {}
                )
            }
            .padding()
        }
        .background(DSKitAsset.Colors.backgroundPrimary.swiftUIColor)
    }
}
