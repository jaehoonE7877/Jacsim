import SwiftUI

public struct JSGlassHeroCard: View {
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
            ZStack(alignment: .bottomLeading) {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 320)
                        .clipped()
                } else {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 320)
                }

                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        Text(isTodayCertified ? "오늘 인증 완료" : "오늘 미인증")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isTodayCertified ? .green : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }

                        HStack(spacing: 12) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(height: 6)
                                    
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: geo.size.width * CGFloat(progress), height: 6)
                                }
                            }
                            .frame(height: 6)

                            Text("\(completedDays)/\(totalDays)일")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(24)
            }
            .frame(height: 320)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JSGlassHeroCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                JSGlassHeroCard(
                    title: "매일 아침 6시 기상하기",
                    subtitle: "성공적인 하루를 위한 시작",
                    progress: 0.7,
                    totalDays: 30,
                    completedDays: 21,
                    isTodayCertified: false,
                    onTap: {}
                )
                .padding()

                JSGlassHeroCard(
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
        .background(Color.gray.opacity(0.1))
    }
}
