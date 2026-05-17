import Domain
import DSKit
import SwiftUI

public struct MeView: View {
    @Bindable var model: MeModel

    public init(model: MeModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            ProfileView(model: model.profile)
        }
    }
}

public struct FriendProfileView: View {
    @State private var model: ProfileModel

    public init(userID: UserID, dependencies: JacsimDependencies) {
        _model = State(initialValue: ProfileModel(userID: userID, dependencies: dependencies))
    }

    public var body: some View {
        ProfileView(model: model)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("언팔로우") {
                            model.unfollowTapped()
                        }
                        Button("차단", role: .destructive) {
                            model.blockTapped()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .frame(width: 44, height: 44)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("친구 프로필 메뉴")
                    .accessibilityHint("언팔로우 또는 차단 메뉴를 엽니다")
                }
            }
    }
}

public struct ProfileView: View {
    @Bindable var model: ProfileModel
    @State private var toastPresented = false

    public init(model: ProfileModel) {
        self.model = model
    }

    public var body: some View {
        ZStack {
            LinearGradient.wallpaperMorning
                .ignoresSafeArea()
            Color.backgroundNormal.opacity(0.18)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: .jsLG) {
                    hero
                    Picker("프로필 탭", selection: $model.segment) {
                        ForEach(ProfileSegment.allCases) { segment in
                            Text(segment.title).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)

                    if model.segment == .tasks {
                        taskGrid
                    } else {
                        bragList
                    }
                }
                .padding(.horizontal, .jsMD)
                .padding(.top, .jsLG)
                .padding(.bottom, 104.jsScaled())
            }
        }
        .navigationTitle(model.user?.displayName ?? "프로필")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.isOwnProfile {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        FriendsSearchView(model: FriendsSearchModel(dependencies: model.dependencies))
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .frame(width: 44, height: 44)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("친구 찾기")
                    .accessibilityHint("친구 검색 화면으로 이동합니다")

                    NavigationLink {
                        SettingView(model: SettingScreenModel(dependencies: model.dependencies))
                    } label: {
                        Image(systemName: "gearshape")
                            .frame(width: 44, height: 44)
                            .accessibilityHidden(true)
                    }
                    .accessibilityLabel("설정")
                    .accessibilityHint("설정 화면으로 이동합니다")
                }
            }
        }
        .jsGlassNavBar()
        .onAppear { model.onAppear() }
        .onChange(of: model.toastMessage) { _, message in
            toastPresented = message != nil
        }
        .jsGlassToast(text: $model.toastMessage, isPresented: $toastPresented)
    }

    private var hero: some View {
        JSGlassCard(accessibilityLabel: "프로필 요약") {
            VStack(alignment: .leading, spacing: .jsMD) {
                HStack(alignment: .top, spacing: .jsMD) {
                    Circle()
                        .fill(Color.forestAccent.opacity(0.18))
                        .frame(width: 68.jsScaled(), height: 68.jsScaled())
                        .overlay {
                            Text(String((model.user?.displayName ?? "작").prefix(1)))
                                .font(.jsSerifTitle)
                                .foregroundStyle(Color.forestAccent)
                        }

                    VStack(alignment: .leading, spacing: .jsMicro) {
                        Text(model.user?.displayName ?? "작심러")
                            .font(.jsSerifDisplay)
                            .foregroundStyle(Color.labelStrong)
                        Text("@\(model.user?.handle ?? "local")")
                            .font(.jsMonoSmall)
                            .foregroundStyle(Color.labelAlternative)
                        if let bio = model.user?.bio {
                            Text(bio)
                                .font(.jsBodySmall)
                                .foregroundStyle(Color.labelNeutral)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer(minLength: .jsXS)
                }

                HStack(spacing: .jsXL) {
                    countLabel(title: "팔로워", count: model.followerCount)
                    countLabel(title: "팔로잉", count: model.followingCount)
                    Spacer()
                }
            }
        }
    }

    private var taskGrid: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            Text("작심")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)

            if !model.canViewTaskList {
                PrivateTaskCell()
            } else if model.tasks.isEmpty {
                EmptyTaskCell(isOwn: model.isOwnProfile)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .jsSM) {
                    ForEach(model.tasks) { task in
                        TaskProfileCell(task: task)
                    }
                }
            }
        }
    }

    private var bragList: some View {
        VStack(alignment: .leading, spacing: .jsSM) {
            Text("자랑")
                .font(.jsSerifTitle)
                .foregroundStyle(Color.labelStrong)

            if model.posts.isEmpty {
                Text("아직 공유된 자랑이 없어요")
                    .font(.jsBodyMedium)
                    .foregroundStyle(Color.labelAlternative)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .jsXL)
            } else {
                ForEach(model.posts) { item in
                    JSBragCard(post: cardModel(for: item))
                }
            }
        }
    }

    private func countLabel(title: String, count: Int) -> some View {
        VStack(alignment: .leading, spacing: .jsMicro) {
            Text("\(count)")
                .font(.jsMonoMedium)
                .foregroundStyle(Color.labelStrong)
            Text(title)
                .font(.jsLabelMedium)
                .foregroundStyle(Color.labelAlternative)
        }
    }

    private func cardModel(for item: FeedPostItem) -> JSBragCardModel {
        JSBragCardModel(
            id: item.post.id.rawValue,
            type: dsBragType(from: item.post.type),
            body: item.post.body,
            imagePaths: item.post.recordImagePaths,
            imageDataItems: item.imageDataItems,
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

private struct TaskProfileCell: View {
    let task: Domain.Task

    var body: some View {
        let badge = SocialVisibilitySupport.visibilityBadge(for: task.visibility)
        JSGlassCard(accessibilityLabel: "\(task.title) 작심") {
            VStack(alignment: .leading, spacing: .jsSM) {
                HStack {
                    Label(badge.title, systemImage: badge.icon)
                        .font(.jsMonoSmall)
                        .foregroundStyle(Color.labelAlternative)
                    Spacer()
                }
                Text(task.title)
                    .font(.jsSerifTitle)
                    .foregroundStyle(Color.labelStrong)
                    .lineLimit(2)
                Text("\(task.completedDays)/\(task.dayArray.count)")
                    .font(.jsMonoMedium)
                    .foregroundStyle(Color.forestAccent)
            }
        }
    }
}

private struct PrivateTaskCell: View {
    var body: some View {
        JSGlassCard(accessibilityLabel: "비공개 작심") {
            VStack(spacing: .jsSM) {
                Image(systemName: "lock.fill")
                    .font(.jsHeadlineMedium)
                    .foregroundStyle(Color.labelAlternative)
                Text("비공개")
                    .font(.jsSerifTitle)
                    .foregroundStyle(Color.labelStrong)
                Text("공개 범위에 따라 제목은 보이지 않아요")
                    .font(.jsBodySmall)
                    .foregroundStyle(Color.labelAlternative)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct EmptyTaskCell: View {
    let isOwn: Bool

    var body: some View {
        JSGlassCard(accessibilityLabel: "작심 없음") {
            Text(isOwn ? "진행 중인 작심이 없어요" : "표시할 작심이 없어요")
                .font(.jsBodyMedium)
                .foregroundStyle(Color.labelAlternative)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .jsLG)
        }
    }
}

#Preview {
    MeView(model: MeModel(dependencies: .test))
}
