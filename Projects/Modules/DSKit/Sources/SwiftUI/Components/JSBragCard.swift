import SwiftUI

public enum BragType: Sendable {
    case graduation
    case streak
    case completion
}

public struct JSBragCardModel: Identifiable, Sendable {
    public let id: UUID
    public let type: BragType
    public let body: String
    public let imagePaths: [String]
    public let cheerCount: Int
    public let commentCount: Int
    public let isOwn: Bool

    public init(
        id: UUID = UUID(),
        type: BragType,
        body: String,
        imagePaths: [String] = [],
        cheerCount: Int,
        commentCount: Int,
        isOwn: Bool
    ) {
        self.id = id
        self.type = type
        self.body = body
        self.imagePaths = Array(imagePaths.prefix(4))
        self.cheerCount = cheerCount
        self.commentCount = commentCount
        self.isOwn = isOwn
    }
}

public struct JSBragCard: View {
    private let post: JSBragCardModel
    private let onDelete: () -> Void

    public init(post: JSBragCardModel, onDelete: @escaping () -> Void = {}) {
        self.post = post
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            header
            Text(post.body)
                .font(.jsSerifQuote)
                .foregroundStyle(Color.labelStrong)
                .fixedSize(horizontal: false, vertical: true)

            if !post.imagePaths.isEmpty {
                imageGrid
            }
            footer
        }
        .padding(.jsLG)
        .background(post.type.tint.opacity(0.12))
        .jsGlassCard(cornerRadius: 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Brag card, \(post.type.title), \(post.cheerCount) cheers, \(post.commentCount) comments")
    }

    private var header: some View {
        HStack(spacing: .jsSM) {
            Image(systemName: post.type.icon)
                .font(.jsHeadline20Bold)
                .foregroundStyle(post.type.tint)
                .frame(width: 36, height: 36)
                .background(post.type.tint.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: .jsMicro) {
                Text(post.type.title)
                    .font(.jsSerifTitle)
                    .foregroundStyle(Color.labelStrong)
                Text(post.type.subtitle)
                    .font(.jsLabelMedium)
                    .foregroundStyle(Color.labelNeutral)
            }
            Spacer()
            if post.isOwn {
                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.jsBodyMedium)
                        .foregroundStyle(Color.labelAlternative)
                        .frame(width: 34, height: 34)
                }
                .accessibilityLabel("자랑 카드 메뉴")
            }
        }
    }

    private var imageGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: .jsXS), count: 2), spacing: .jsXS) {
            ForEach(Array(post.imagePaths.enumerated()), id: \.offset) { index, path in
                RoundedRectangle(cornerRadius: .jsCornerSmall, style: .continuous)
                    .fill(LinearGradient.wallpaperDusk)
                    .overlay {
                        Text(URL(fileURLWithPath: path).lastPathComponent.isEmpty ? "\(index + 1)" : URL(fileURLWithPath: path).lastPathComponent)
                            .font(.jsMonoSmall)
                            .foregroundStyle(Color.labelStrong)
                            .lineLimit(1)
                            .padding(.jsXS)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .accessibilityLabel("자랑 이미지 \(index + 1)")
            }
        }
    }

    private var footer: some View {
        HStack(spacing: .jsLG) {
            Label("\(post.cheerCount)", systemImage: "hands.clap")
            Label("\(post.commentCount)", systemImage: "bubble.left")
            Spacer()
        }
        .font(.jsMonoSmall)
        .foregroundStyle(Color.labelNeutral)
    }
}

private extension BragType {
    var title: String {
        switch self {
        case .graduation: return "7일, 완주."
        case .streak: return "연속 기록"
        case .completion: return "오늘 완료"
        }
    }

    var subtitle: String {
        switch self {
        case .graduation: return "졸업 순간"
        case .streak: return "꾸준함 자랑"
        case .completion: return "작은 성취"
        }
    }

    var icon: String {
        switch self {
        case .graduation: return "sparkles"
        case .streak: return "flame"
        case .completion: return "checkmark.seal"
        }
    }

    var tint: Color {
        switch self {
        case .graduation: return Color.achievement
        case .streak: return Color.streakActive
        case .completion: return Color.forestAccent
        }
    }
}

private struct JSBragCardPreview: View {
    var body: some View {
        JSBragCard(
            post: JSBragCardModel(
                type: .graduation,
                body: "처음엔 3일도 어려웠는데, 오늘은 7일을 채웠어요.",
                imagePaths: ["morning.png", "forest.png", "dusk.png"],
                cheerCount: 24,
                commentCount: 6,
                isOwn: true
            )
        )
        .padding(.jsLG)
        .background(Color.backgroundNormal)
    }
}

#Preview("JSBragCard - Light") {
    JSBragCardPreview()
        .preferredColorScheme(.light)
}

#Preview("JSBragCard - Dark") {
    JSBragCardPreview()
        .preferredColorScheme(.dark)
}

#Preview("JSBragCard - Accessibility") {
    JSBragCardPreview()
        .dynamicTypeSize(.accessibility3)
}
