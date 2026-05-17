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
                        colors: [.primaryNormal.opacity(0.6), .primaryStrong.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 320)
                }

                LinearGradient(
                    colors: [.clear, Color.surfaceOverlay.opacity(0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        Text(isTodayCertified ? "오늘 인증 완료" : "오늘 미인증")
                            .font(.jsLabel12Bold)
                            .foregroundColor(isTodayCertified ? Color.positive : Color.backgroundNormal)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.jsDisplay28Bold)
                            .foregroundColor(Color.backgroundNormal)
                            .lineLimit(2)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.jsBody15Medium)
                                .foregroundColor(Color.backgroundNormal.opacity(0.8))
                                .lineLimit(1)
                        }

                        HStack(spacing: 12) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.backgroundNormal.opacity(0.3))
                                        .frame(height: 6)
                                    
                                    Capsule()
                                        .fill(Color.backgroundNormal)
                                        .frame(width: geo.size.width * CGFloat(progress), height: 6)
                                }
                            }
                            .frame(height: 6)

                            Text("\(completedDays)/\(totalDays)일")
                                .font(.jsLabel14Bold)
                                .foregroundColor(Color.backgroundNormal)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(24)
            }
            .frame(height: 320)
            .cornerRadius(24)
            .jsShadow(.large)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct JSGlassHeroCardPreview: View {
    var body: some View {
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
            }
        }
        .background(Color.backgroundAlternative)
    }
}

#Preview("JSGlassHeroCard - Light") {
    JSGlassHeroCardPreview()
        .preferredColorScheme(.light)
}

#Preview("JSGlassHeroCard - Dark") {
    JSGlassHeroCardPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSGlassHeroCard - Accessibility") {
    JSGlassHeroCardPreview()
        .dynamicTypeSize(.accessibility3)
}
