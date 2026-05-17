import Foundation
import SwiftUI
import UIKit

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
    public let imageDataItems: [Data]
    public let cheerCount: Int
    public let commentCount: Int
    public let isOwn: Bool
    public let authorName: String?
    public let taskTitle: String?
    public let hasCheered: Bool

    public init(
        id: UUID = UUID(),
        type: BragType,
        body: String,
        imagePaths: [String] = [],
        imageDataItems: [Data] = [],
        cheerCount: Int,
        commentCount: Int,
        isOwn: Bool,
        authorName: String? = nil,
        taskTitle: String? = nil,
        hasCheered: Bool = false
    ) {
        self.id = id
        self.type = type
        self.body = body
        self.imagePaths = Array(imagePaths.prefix(4))
        self.imageDataItems = Array(imageDataItems.prefix(4))
        self.cheerCount = cheerCount
        self.commentCount = commentCount
        self.isOwn = isOwn
        self.authorName = authorName
        self.taskTitle = taskTitle
        self.hasCheered = hasCheered
    }
}

public struct JSBragCard: View {
    private let post: JSBragCardModel
    private let onDelete: () -> Void
    private let onCheer: () -> Void
    private let onComment: () -> Void
    private let onFollowChallenge: () -> Void

    public init(
        post: JSBragCardModel,
        onDelete: @escaping () -> Void = {},
        onCheer: @escaping () -> Void = {},
        onComment: @escaping () -> Void = {},
        onFollowChallenge: @escaping () -> Void = {}
    ) {
        self.post = post
        self.onDelete = onDelete
        self.onCheer = onCheer
        self.onComment = onComment
        self.onFollowChallenge = onFollowChallenge
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            header
            Text(post.body)
                .font(.jsSerifQuote)
                .foregroundStyle(Color.labelStrong)
                .fixedSize(horizontal: false, vertical: true)

            if post.imageCount > 0 {
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
                Text(headerSubtitle)
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
            ForEach(0..<post.imageCount, id: \.self) { index in
                imageCell(index: index)
                    .aspectRatio(1, contentMode: .fit)
                    .accessibilityLabel("자랑 이미지 \(index + 1)")
            }
        }
    }

    @ViewBuilder
    private func imageCell(index: Int) -> some View {
        if post.imageDataItems.indices.contains(index),
           let image = UIImage(data: post.imageDataItems[index]) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: .jsCornerSmall, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: .jsCornerSmall, style: .continuous)
                .fill(LinearGradient.wallpaperDusk)
                .overlay {
                    Text(post.imageName(at: index))
                        .font(.jsMonoSmall)
                        .foregroundStyle(Color.labelStrong)
                        .lineLimit(1)
                        .padding(.jsXS)
                }
        }
    }

    private var footer: some View {
        HStack(spacing: .jsLG) {
            Button(action: onCheer) {
                Label("\(post.cheerCount)", systemImage: post.hasCheered ? "hands.clap.fill" : "hands.clap")
            }
            .jsTouchTarget()
            .accessibilityLabel("응원 \(post.cheerCount)개")
            .accessibilityHint("응원을 보냅니다")
            .sensoryFeedback(.success, trigger: post.hasCheered)

            Button(action: onComment) {
                Label("\(post.commentCount)", systemImage: "bubble.left")
            }
            .jsTouchTarget()
            .accessibilityLabel("댓글 \(post.commentCount)개")
            .accessibilityHint("댓글을 엽니다")

            Button(action: onFollowChallenge) {
                Label("따라하기", systemImage: "arrow.triangle.branch")
            }
            .font(.jsBodySmall)
            .jsTouchTarget()
            .accessibilityLabel("이 작심 따라하기")
            .accessibilityHint("이 작심을 내 작심으로 시작합니다")

            Spacer()
        }
        .font(.jsMonoSmall)
        .foregroundStyle(Color.labelNeutral)
        .buttonStyle(.plain)
    }

    private var headerSubtitle: String {
        let parts: [String] = [post.authorName, post.taskTitle].compactMap { value in
            guard let value, !value.isEmpty else { return nil }
            return value
        }
        guard !parts.isEmpty else { return post.type.subtitle }
        return parts.joined(separator: " · ")
    }
}

private extension JSBragCardModel {
    var imageCount: Int {
        max(imagePaths.count, imageDataItems.count)
    }

    func imageName(at index: Int) -> String {
        guard imagePaths.indices.contains(index) else {
            return "\(index + 1)"
        }
        let name = URL(fileURLWithPath: imagePaths[index]).lastPathComponent
        return name.isEmpty ? "\(index + 1)" : name
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
                isOwn: true,
                authorName: "태양",
                taskTitle: "매일 10분 독서",
                hasCheered: true
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
