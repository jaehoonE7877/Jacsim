import Core
import Data
import Domain
import ExternalInterface
import Foundation
import WidgetKit

public struct JacsimDependencies: Sendable {
    public var appPreferences: AppPreferencesPort
    public var notificationScheduler: NotificationSchedulerPort
    public var imageStore: ImageStorePort
    public var taskRepository: TaskRepositoryPort
    public var userSettingsRepository: UserSettingsRepositoryPort
    public var socialUserRepository: SocialUserRepositoryPort
    public var followRepository: FollowRepositoryPort
    public var bragPostRepository: BragPostRepositoryPort
    public var cheerRepository: CheerRepositoryPort
    public var commentRepository: CommentRepositoryPort
    public var followChallengeRepository: FollowChallengeRepositoryPort
    public var aiCoachClient: any AICoachClientPort
    public var seedSocialIfNeeded: @Sendable () async -> Void
    public var taskQueryClient: TaskQueryClientPort
    public var taskCommandClient: TaskCommandClientPort
    public var stageFlowClient: StageFlowClientPort
    public var certificationClient: CertificationClientPort
    public var activeTaskService: ActiveTaskService
    public var calendarEventService: CalendarEventService
    public var challengeStateService: ChallengeStateService

    public init(
        appPreferences: AppPreferencesPort,
        notificationScheduler: NotificationSchedulerPort,
        imageStore: ImageStorePort,
        taskRepository: TaskRepositoryPort,
        userSettingsRepository: UserSettingsRepositoryPort,
        socialUserRepository: SocialUserRepositoryPort,
        followRepository: FollowRepositoryPort,
        bragPostRepository: BragPostRepositoryPort,
        cheerRepository: CheerRepositoryPort,
        commentRepository: CommentRepositoryPort,
        followChallengeRepository: FollowChallengeRepositoryPort,
        aiCoachClient: any AICoachClientPort,
        seedSocialIfNeeded: @escaping @Sendable () async -> Void,
        taskQueryClient: TaskQueryClientPort,
        taskCommandClient: TaskCommandClientPort,
        stageFlowClient: StageFlowClientPort,
        certificationClient: CertificationClientPort,
        activeTaskService: ActiveTaskService,
        calendarEventService: CalendarEventService,
        challengeStateService: ChallengeStateService
    ) {
        self.appPreferences = appPreferences
        self.notificationScheduler = notificationScheduler
        self.imageStore = imageStore
        self.taskRepository = taskRepository
        self.userSettingsRepository = userSettingsRepository
        self.socialUserRepository = socialUserRepository
        self.followRepository = followRepository
        self.bragPostRepository = bragPostRepository
        self.cheerRepository = cheerRepository
        self.commentRepository = commentRepository
        self.followChallengeRepository = followChallengeRepository
        self.aiCoachClient = aiCoachClient
        self.seedSocialIfNeeded = seedSocialIfNeeded
        self.taskQueryClient = taskQueryClient
        self.taskCommandClient = taskCommandClient
        self.stageFlowClient = stageFlowClient
        self.certificationClient = certificationClient
        self.activeTaskService = activeTaskService
        self.calendarEventService = calendarEventService
        self.challengeStateService = challengeStateService
    }
}

public extension JacsimDependencies {
    static let live: Self = {
        let taskRepositoryAdapter = SwiftDataTaskRepositoryAdapter()
        let taskRepository = TaskRepositoryPort(
            fetchActiveTasks: { await taskRepositoryAdapter.fetchActiveTasks() },
            fetchTask: { await taskRepositoryAdapter.fetchTask(id: $0) },
            addTask: { try await taskRepositoryAdapter.addTask($0) },
            updateTask: { try await taskRepositoryAdapter.updateTask($0) },
            deleteTask: { try await taskRepositoryAdapter.deleteTask(id: $0) },
            fetchTasksByStatus: { await taskRepositoryAdapter.fetchTasksByStatus($0) }
        )

        let taskStatusService = TaskStatusService()
        let stageEvaluationService = StageEvaluationService()
        let taskUpdateUseCase = TaskUpdateUseCase(updateTask: { try await taskRepositoryAdapter.updateTask($0) })
        let stageProgressionUseCase = StageProgressionUseCase(
            fetchTask: { await taskRepositoryAdapter.fetchTask(id: $0) },
            updateTask: { try await taskRepositoryAdapter.updateTask($0) }
        )
        let certificationUseCase = CertificationUseCase(
            fetchTask: { await taskRepositoryAdapter.fetchTask(id: $0) },
            updateTask: { try await taskRepositoryAdapter.updateTask($0) }
        )

        let notificationAdapter = LocalNotificationSchedulerAdapter(localUserId: SocialLocalSession.currentUserID)
        let notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { try await notificationAdapter.scheduleReminder(taskId: $0, title: $1, time: $2) },
            cancelReminder: { await notificationAdapter.cancelReminder(taskId: $0) },
            cancelAllReminders: { await notificationAdapter.cancelAllReminders() },
            requestAuthorization: { try await notificationAdapter.requestAuthorization() },
            scheduleSocial: { try await notificationAdapter.scheduleSocial(trigger: $0, context: $1) },
            cancelSocial: { try await notificationAdapter.cancelSocial(matching: $0) }
        )

        let jacsimClient = JacsimClientPort(
            fetchActiveTasks: { try await taskRepository.fetchActiveTasks() },
            fetchTask: { try await taskRepository.fetchTask($0) },
            addTask: { task in
                let startTime = Date()
                try await taskRepository.addTask(task)
                Logger.taskSaved(duration: Date().timeIntervalSince(startTime))
            },
            updateTask: { try await taskRepository.updateTask($0) },
            deleteTask: { try await taskRepository.deleteTask($0) },
            fetchTasksByStatus: { try await taskRepository.fetchTasksByStatus($0) },
            fetchIsSuccess: {
                let allDone = try await taskRepository.fetchTasksByStatus(.done)
                return taskStatusService.filterSuccessTasks(allDone)
            },
            fetchIsFail: {
                let allDone = try await taskRepository.fetchTasksByStatus(.done)
                return taskStatusService.filterFailTasks(allDone)
            },
            deleteAlarm: { _ in },
            updateTaskInfo: { task, title, successTarget, isAlarmEnabled, alarmDate in
                var task = task
                task.isNotificationEnabled = isAlarmEnabled
                task.alarm = isAlarmEnabled ? alarmDate : nil
                do {
                    _ = try await taskUpdateUseCase.updateTaskInfo(
                        task: task,
                        title: title,
                        durationDays: successTarget,
                        isNotificationEnabled: isAlarmEnabled,
                        alarmDate: alarmDate
                    )
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            evaluateStageResult: { stage in
                stageEvaluationService.evaluateStage(
                    endDate: stage.endDate,
                    durationDays: stage.durationDays,
                    successDays: stage.successDays
                )
            },
            createNextStage: { taskId in
                do {
                    try await stageProgressionUseCase.createNextStage(for: taskId)
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            updateMemo: { taskId, index, memo in
                do {
                    try await certificationUseCase.updateMemo(
                        taskId: taskId,
                        index: index,
                        memo: memo
                    )
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            resetStageRecords: { taskId in
                do {
                    try await stageProgressionUseCase.resetStageRecords(for: taskId)
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            certifyToday: { taskId, index, memo, imagePath in
                let startTime = Date()
                let beforeTask = await taskRepositoryAdapter.fetchTask(id: taskId)
                Logger.certificationSaving(
                    taskId: taskId.rawValue.uuidString,
                    index: index,
                    memo: memo,
                    imagePath: imagePath
                )
                do {
                    try await certificationUseCase.certifyToday(
                        taskId: taskId,
                        index: index,
                        memo: memo,
                        imagePath: imagePath
                    )
                    Logger.certificationSavedToSwiftData(
                        duration: Date().timeIntervalSince(startTime)
                    )
                    WidgetCenter.shared.reloadTimelines(ofKind: "TodayJacsimWidget")
                    WidgetCenter.shared.reloadTimelines(ofKind: "StreakWidget")
                    if let beforeTask,
                       var afterTask = await taskRepositoryAdapter.fetchTask(id: taskId),
                       let graduation = StageGraduationDetector().graduationContext(before: beforeTask, after: afterTask) {
                        if let lastIndex = afterTask.stages.indices.last {
                            afterTask.stages[lastIndex].result = .success
                            try? await taskRepositoryAdapter.updateTask(afterTask)
                        }
                        NotificationCenter.default.post(name: .jacsimStageGraduated, object: graduation)
                    }
                } catch {
                    Logger.certificationFailed(error: error)
                }
            }
        )

        let taskQueryClient = TaskQueryClientPort(
            fetchActiveTasks: { try await jacsimClient.fetchActiveTasks() },
            fetchTask: { try await jacsimClient.fetchTask($0) },
            fetchTasksByStatus: { try await jacsimClient.fetchTasksByStatus($0) },
            fetchIsSuccess: { try await jacsimClient.fetchIsSuccess() },
            fetchIsFail: { try await jacsimClient.fetchIsFail() }
        )
        let taskCommandClient = TaskCommandClientPort(
            addTask: { try await jacsimClient.addTask($0) },
            updateTask: { try await jacsimClient.updateTask($0) },
            deleteTask: { try await jacsimClient.deleteTask($0) },
            updateTaskInfo: { await jacsimClient.updateTaskInfo($0, $1, $2, $3, $4) },
            updateVisibility: { taskId, visibility in
                guard var task = try await taskRepository.fetchTask(taskId) else { return }
                task.visibility = visibility
                try await taskRepository.updateTask(task)
            }
        )
        let stageFlowClient = StageFlowClientPort(
            evaluateStageResult: { await jacsimClient.evaluateStageResult($0) },
            createNextStage: { await jacsimClient.createNextStage($0) },
            resetStageRecords: { await jacsimClient.resetStageRecords($0) }
        )
        let certificationClient = CertificationClientPort(
            updateMemo: { await jacsimClient.updateMemo($0, $1, $2) },
            certifyToday: { await jacsimClient.certifyToday($0, $1, $2, $3) }
        )

        let imageStoreAdapter = DocumentImageStoreAdapter()
        let imageStore = ImageStorePort(
            saveImage: { try await imageStoreAdapter.saveImage(key: $0, data: $1) },
            loadImage: { await imageStoreAdapter.loadImage(key: $0) },
            deleteImage: { await imageStoreAdapter.deleteImage(key: $0) },
            imageExists: { await imageStoreAdapter.imageExists(key: $0) }
        )

        let userSettingsAdapter = UserSettingsRepositoryAdapter()
        let userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await userSettingsAdapter.isNotificationEnabled() },
            getAllReminders: { await userSettingsAdapter.getAllReminders() },
            updateNotificationEnabled: { await userSettingsAdapter.updateNotificationEnabled($0) },
            wallpaperRaw: { await userSettingsAdapter.wallpaperRaw() },
            updateWallpaperRaw: { await userSettingsAdapter.updateWallpaperRaw($0) },
            socialNotificationSettings: { await userSettingsAdapter.socialNotificationSettings() },
            updateSocialNotificationSettings: { await userSettingsAdapter.updateSocialNotificationSettings($0) }
        )

        let socialUserRepositoryAdapter = SocialUserRepositoryAdapter()
        let socialUserRepository = SocialUserRepositoryPort(
            fetchUser: { try await socialUserRepositoryAdapter.fetchUser(id: $0) },
            fetchUserByHandle: { try await socialUserRepositoryAdapter.fetchUserByHandle($0) },
            searchUsers: { try await socialUserRepositoryAdapter.searchUsers(query: $0) },
            upsertUser: { try await socialUserRepositoryAdapter.upsertUser($0) }
        )

        let followRepositoryAdapter = FollowRepositoryAdapter()
        let followRepository = FollowRepositoryPort(
            fetchPendingRequests: { try await followRepositoryAdapter.fetchPendingRequests(for: $0) },
            fetchAccepted: { try await followRepositoryAdapter.fetchAccepted(for: $0) },
            fetchAll: { try await followRepositoryAdapter.fetchAll(for: $0) },
            upsertFollow: { try await followRepositoryAdapter.upsertFollow($0) }
        )

        let bragPostRepositoryAdapter = BragPostRepositoryAdapter()
        let bragPostRepository = BragPostRepositoryPort(
            fetchFeed: { try await bragPostRepositoryAdapter.fetchFeed(for: $0, follow: $1) },
            fetchPosts: { try await bragPostRepositoryAdapter.fetchPosts(authorID: $0) },
            createPost: { try await bragPostRepositoryAdapter.createPost($0) },
            deletePost: { try await bragPostRepositoryAdapter.deletePost(id: $0) }
        )

        let cheerRepositoryAdapter = CheerRepositoryAdapter()
        let cheerRepository = CheerRepositoryPort(
            addUnique: { try await cheerRepositoryAdapter.addUnique(postId: $0, userId: $1) },
            fetchCheers: { try await cheerRepositoryAdapter.fetchCheers(postId: $0) }
        )

        let commentRepositoryAdapter = CommentRepositoryAdapter()
        let commentRepository = CommentRepositoryPort(
            addComment: { try await commentRepositoryAdapter.addComment($0) },
            fetchComments: { try await commentRepositoryAdapter.fetchComments(postId: $0) },
            deleteComment: { try await commentRepositoryAdapter.deleteComment(id: $0) }
        )

        let followChallengeRepositoryAdapter = FollowChallengeRepositoryAdapter()
        let followChallengeRepository = FollowChallengeRepositoryPort(
            recordFollowChallenge: { try await followChallengeRepositoryAdapter.recordFollowChallenge($0) },
            fetchByCopier: { try await followChallengeRepositoryAdapter.fetchByCopier($0) }
        )

        let seedSocialUseCase = SeedSocialUseCase()

        return JacsimDependencies(
            appPreferences: UserDefaultsAppPreferencesAdapter().makePort(),
            notificationScheduler: notificationScheduler,
            imageStore: imageStore,
            taskRepository: taskRepository,
            userSettingsRepository: userSettingsRepository,
            socialUserRepository: socialUserRepository,
            followRepository: followRepository,
            bragPostRepository: bragPostRepository,
            cheerRepository: cheerRepository,
            commentRepository: commentRepository,
            followChallengeRepository: followChallengeRepository,
            aiCoachClient: RealAICoachClientAdapter(),
            seedSocialIfNeeded: {
                do {
                    try await seedSocialUseCase.seedIfNeeded()
                } catch {
                    Logger.certificationFailed(error: error)
                }
            },
            taskQueryClient: taskQueryClient,
            taskCommandClient: taskCommandClient,
            stageFlowClient: stageFlowClient,
            certificationClient: certificationClient,
            activeTaskService: ActiveTaskService(),
            calendarEventService: CalendarEventService(),
            challengeStateService: ChallengeStateService()
        )
    }()

    static let test = JacsimDependencies(
        appPreferences: .inMemory(),
        notificationScheduler: NotificationSchedulerPort(
            scheduleDailyReminder: { _, _, _ in },
            cancelReminder: { _ in },
            cancelAllReminders: { },
            requestAuthorization: { false }
        ),
        imageStore: ImageStorePort(
            saveImage: { _, _ in "" },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
        ),
        taskRepository: TaskRepositoryPort(
            fetchActiveTasks: { [] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        ),
        userSettingsRepository: UserSettingsRepositoryPort(
            isNotificationEnabled: { false },
            getAllReminders: { [] },
            updateNotificationEnabled: { _ in }
        ),
        socialUserRepository: SocialUserRepositoryPort(
            fetchUser: { _ in nil },
            fetchUserByHandle: { _ in nil },
            searchUsers: { _ in [] },
            upsertUser: { _ in }
        ),
        followRepository: FollowRepositoryPort(
            fetchPendingRequests: { _ in [] },
            fetchAccepted: { _ in [] },
            fetchAll: { _ in [] },
            upsertFollow: { _ in }
        ),
        bragPostRepository: BragPostRepositoryPort(
            fetchFeed: { _, _ in [] },
            fetchPosts: { _ in [] },
            createPost: { _ in },
            deletePost: { _ in }
        ),
        cheerRepository: CheerRepositoryPort(
            addUnique: { _, _ in true },
            fetchCheers: { _ in [] }
        ),
        commentRepository: CommentRepositoryPort(
            addComment: { _ in },
            fetchComments: { _ in [] },
            deleteComment: { _ in }
        ),
        followChallengeRepository: FollowChallengeRepositoryPort(
            recordFollowChallenge: { _ in },
            fetchByCopier: { _ in [] }
        ),
        aiCoachClient: MockAICoachClientAdapter(),
        seedSocialIfNeeded: {},
        taskQueryClient: TaskQueryClientPort(
            fetchActiveTasks: { [] },
            fetchTask: { _ in nil },
            fetchTasksByStatus: { _ in [] },
            fetchIsSuccess: { [] },
            fetchIsFail: { [] }
        ),
        taskCommandClient: TaskCommandClientPort(
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            updateTaskInfo: { _, _, _, _, _ in }
        ),
        stageFlowClient: StageFlowClientPort(
            evaluateStageResult: { _ in .inProgress },
            createNextStage: { _ in },
            resetStageRecords: { _ in }
        ),
        certificationClient: CertificationClientPort(
            updateMemo: { _, _, _ in },
            certifyToday: { _, _, _, _ in }
        ),
        activeTaskService: ActiveTaskService(),
        calendarEventService: CalendarEventService(),
        challengeStateService: ChallengeStateService()
    )
}
