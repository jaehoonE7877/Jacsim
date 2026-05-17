import Domain
import Foundation
import SwiftData

public actor SeedSocialUseCase {
    private enum Constants {
        static let settingsID = "global"
        static let currentUserID = UUID(uuidString: "00000000-0000-4000-8000-000000000006")!
    }

    private let container: ModelContainer

    public init(container: ModelContainer = SwiftDataStack.shared.container) {
        self.container = container
    }

    public func seedIfNeeded() async throws {
        let context = ModelContext(container)
        let settings = try fetchOrCreateSettings(in: context)

        let users = seedUsers()
        let existingUsers = try context.fetch(FetchDescriptor<UserModel>())
        let posts = seedPosts()
        let existingPosts = try context.fetch(FetchDescriptor<BragPostModel>())
        let existingVisibilities = try context.fetch(FetchDescriptor<BragPostVisibilityModel>())
        let seedVisibilitiesComplete = posts.allSatisfy { post in
            existingVisibilities.contains { $0.postId == post.id.rawValue }
        }
        if settings.seededSocialV1 == true,
           existingUsers.count >= users.count,
           existingPosts.count >= posts.count,
           seedVisibilitiesComplete {
            return
        }

        for user in users where !existingUsers.contains(where: { $0.id == user.id.rawValue }) {
            context.insert(mapToSwiftDataModel(user))
        }

        for post in posts where !existingPosts.contains(where: { $0.id == post.id.rawValue }) {
            context.insert(mapToSwiftDataModel(post))
        }

        for post in posts where !existingVisibilities.contains(where: { $0.postId == post.id.rawValue }) {
            context.insert(
                BragPostVisibilityModel(
                    postId: post.id.rawValue,
                    visibilityRaw: post.visibility.rawValue
                )
            )
        }

        settings.seededSocialV1 = true
        try context.save()
        print("SeedSocialUseCase: inserted \(users.count) mock users and \(posts.count) brag posts")
    }

    private func fetchOrCreateSettings(in context: ModelContext) throws -> AppSettingsModel {
        let settings = try context.fetch(FetchDescriptor<AppSettingsModel>())
        if let existing = settings.first(where: { $0.id == Constants.settingsID }) {
            return existing
        }

        let newSettings = AppSettingsModel(id: Constants.settingsID)
        context.insert(newSettings)
        return newSettings
    }

    private nonisolated func seedUsers() -> [Domain.User] {
        [
            user(index: 1, handle: "soyoung", displayName: "소영", bio: "아침 루틴을 차곡차곡 쌓고 있어요."),
            user(index: 2, handle: "minjun", displayName: "민준", bio: "작은 인증을 오래 이어갑니다."),
            user(index: 3, handle: "hyeoncheol", displayName: "현철", bio: "기록으로 생활 리듬을 다듬는 중."),
            user(index: 4, handle: "sunho", displayName: "선호", bio: "운동과 독서를 함께 이어가요."),
            user(index: 5, handle: "jiwon", displayName: "지원", bio: "매일 한 장면씩 남깁니다."),
            Domain.User(
                id: UserID(Constants.currentUserID),
                handle: "taeyang",
                displayName: "태양",
                bio: "오늘의 작심을 이어가는 중"
            )
        ]
    }

    private nonisolated func seedPosts() -> [Domain.BragPost] {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: Date())
        return [
            post(index: 1, authorIndex: 1, type: .streak, body: "아침 산책 7일째. 오늘은 숲길이 훨씬 가벼웠어요.", image: "seed-soyoung-walk.png", dayOffset: -1, base: base),
            post(index: 2, authorIndex: 2, type: .completion, body: "퇴근 후 20분 독서 완료. 짧아도 매일 하니까 남네요.", image: "seed-minjun-book.png", dayOffset: -2, base: base),
            post(index: 3, authorIndex: 3, type: .graduation, body: "14일 물 마시기 작심 완주. 다음은 30일로 갑니다.", image: "seed-hyeoncheol-water.png", dayOffset: -3, base: base),
            post(index: 4, authorIndex: 4, type: .streak, body: "헬스장 출석 10일째. 숫자로 보니 계속하고 싶어져요.", image: "seed-sunho-gym.png", dayOffset: -4, base: base),
            post(index: 5, authorIndex: 5, type: .completion, body: "감사 일기 한 줄. 오늘은 늦지 않게 적었습니다.", image: "seed-jiwon-journal.png", dayOffset: -5, base: base)
        ]
    }

    private nonisolated func user(
        index: Int,
        handle: String,
        displayName: String,
        bio: String
    ) -> Domain.User {
        Domain.User(
            id: UserID(seedUUID(index)),
            handle: handle,
            displayName: displayName,
            bio: bio
        )
    }

    private nonisolated func post(
        index: Int,
        authorIndex: Int,
        type: Domain.BragType,
        body: String,
        image: String,
        dayOffset: Int,
        base: Date
    ) -> Domain.BragPost {
        let createdAt = Calendar.current.date(byAdding: .day, value: dayOffset, to: base) ?? base
        return Domain.BragPost(
            id: BragPostID(seedUUID(100 + index)),
            authorId: UserID(seedUUID(authorIndex)),
            type: type,
            body: body,
            recordImagePaths: [image],
            visibility: .public,
            createdAt: createdAt
        )
    }

    private nonisolated func seedUUID(_ index: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-4000-8000-%012d", index))!
    }
}
