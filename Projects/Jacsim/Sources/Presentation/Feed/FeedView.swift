import Domain
import DSKit
import SwiftUI

public struct FeedView: View {
    @Bindable var model: FeedModel
    @State private var toastPresented = false

    public init(model: FeedModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.wallpaperForest
                    .ignoresSafeArea()
                Color.backgroundNormal.opacity(0.16)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("친구들의 기록")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        model.composerButtonTapped()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.jsBodyMedium)
                            .accessibilityHidden(true)
                    }
                    .jsTouchTarget()
                    .accessibilityLabel("자랑 글 쓰기")
                    .accessibilityHint("자랑 글 작성 화면을 엽니다")
                }
            }
            .jsGlassNavBar()
            .sheet(isPresented: $model.isComposerPresented) {
                NavigationStack {
                    BragComposerView(
                        model: BragComposerModel(
                            dependencies: model.dependencies,
                            prefill: model.composerPrefill,
                            onCompleted: {
                                model.composerCompleted()
                            }
                        )
                    )
                }
            }
            .overlay { commentSheet }
            .onAppear { model.onAppear() }
            .refreshable { await model.refresh() }
            .onChange(of: model.toastMessage) { _, message in
                toastPresented = message != nil
            }
            .jsGlassToast(text: $model.toastMessage, isPresented: $toastPresented)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            Picker("피드 모드", selection: $model.mode) {
                ForEach(FeedMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, .jsMD)

            if model.isLoading {
                ProgressView()
                    .tint(.forestAccent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if model.visiblePosts.isEmpty {
                FeedEmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: .jsMD) {
                        ForEach(model.visiblePosts) { item in
                            JSBragCard(
                                post: cardModel(for: item),
                                onDelete: { model.deleteTapped(item) },
                                onCheer: { model.cheerTapped(item) },
                                onComment: { model.commentTapped(item) },
                                onFollowChallenge: { model.followChallengeTapped(item) }
                            )
                            .onAppear {
                                model.loadNextPageIfNeeded(current: item)
                            }
                        }
                    }
                    .padding(.horizontal, .jsMD)
                    .padding(.bottom, 96.jsScaled())
                }
            }
        }
        .padding(.top, .jsSM)
    }

    @ViewBuilder
    private var commentSheet: some View {
        JSBottomSheet(
            isPresented: Binding(
                get: { model.selectedCommentPost != nil },
                set: { isPresented in
                    if !isPresented {
                        model.selectedCommentPost = nil
                    }
                }
            ),
            style: .fixed(height: 420.jsScaled()),
            showDragIndicator: true,
            allowsInteractiveDismiss: true,
            glass: true
        ) {
            if let item = model.selectedCommentPost {
                CommentSheetView(model: model, item: item)
            }
        }
    }

    private func cardModel(for item: FeedPostItem) -> JSBragCardModel {
        JSBragCardModel(
            id: item.post.id.rawValue,
            type: dsBragType(from: item.post.type),
            body: item.post.body,
            imagePaths: item.post.recordImagePaths,
            cheerCount: item.post.cheers.count,
            commentCount: item.post.comments.count,
            isOwn: item.isOwn,
            authorName: item.author.displayName,
            taskTitle: item.taskTitle,
            hasCheered: item.hasCheered
        )
    }

    private func dsBragType(from type: Domain.BragType) -> DSKit.BragType {
        switch type {
        case .graduation:
            return .graduation
        case .streak:
            return .streak
        case .completion:
            return .completion
        }
    }
}

private struct FeedEmptyStateView: View {
    var body: some View {
        VStack(spacing: .jsSM) {
            Image(systemName: "person.2.wave.2.fill")
                .font(.jsDisplayScaledSemiBold(size: 40))
                .foregroundStyle(Color.forestAccent)
            Text("아직 볼 수 있는 기록이 없어요")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)
            Text("친구를 연결하면 공개된 자랑이 여기에 쌓입니다")
                .font(.jsBodySmall)
                .foregroundStyle(Color.labelAlternative)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, .jsXL)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("피드 비어 있음")
    }
}

private struct CommentSheetView: View {
    @Bindable var model: FeedModel
    let item: FeedPostItem

    var body: some View {
        VStack(alignment: .leading, spacing: .jsMD) {
            Text("댓글")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)
                .padding(.horizontal, .jsLG)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: .jsSM) {
                    if item.post.comments.isEmpty {
                        Text("첫 댓글을 남겨보세요")
                            .font(.jsBodySmall)
                            .foregroundStyle(Color.labelAlternative)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, .jsLG)
                    } else {
                        ForEach(item.post.comments) { comment in
                            VStack(alignment: .leading, spacing: .jsMicro) {
                                Text(comment.authorId == SocialLocalSession.currentUserID ? "나" : "친구")
                                    .font(.jsMonoSmall)
                                    .foregroundStyle(Color.labelAlternative)
                                Text(comment.body)
                                    .font(.jsBodyMedium)
                                    .foregroundStyle(Color.labelStrong)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.jsSM)
                            .background(Color.surfaceElevated.opacity(0.28), in: RoundedRectangle(cornerRadius: .jsRadiusMD))
                        }
                    }
                }
                .padding(.horizontal, .jsLG)
            }

            HStack(spacing: .jsSM) {
                JSInputField(
                    title: "",
                    placeholder: "댓글 입력",
                    text: $model.commentDraft
                )
                JSButton(
                    title: "등록",
                    style: .primary,
                    size: .medium,
                    isEnabled: !model.commentDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    action: model.addComment
                )
                .frame(width: 84.jsScaled())
            }
            .padding(.horizontal, .jsLG)
            .padding(.bottom, .jsMD)
        }
        .accessibilityLabel("댓글 시트")
    }
}

#Preview {
    FeedView(model: FeedModel(dependencies: .test))
}
