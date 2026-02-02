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
            ZStack(alignment: .bottomLeading) {
                // Image/Background Area
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
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Gradient Overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Content
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        StatusBadge(isCertified: isTodayCertified)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(1)
                        }

                        // Unified Progress Bar
                        HStack(spacing: 12) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.25))
                                        .frame(height: 6)
                                    
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: geo.size.width * CGFloat(progress), height: 6)
                                }
                            }
                            .frame(height: 6)

                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(minWidth: 50, alignment: .trailing)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .frame(height: 320)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: .black.opacity(0.12),
                        radius: 16,
                        x: 0,
                        y: 8
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct StatusBadge: View {
    let isCertified: Bool
    
    var body: some View {
        Text(isCertified ? "오늘 인증 완료" : "오늘 미인증")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(isCertified ? .green : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
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
        .background(Color.gray.opacity(0.1))
    }
}
