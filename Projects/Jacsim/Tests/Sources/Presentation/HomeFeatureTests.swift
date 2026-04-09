import Foundation
import Testing
import ComposableArchitecture
import Domain
import JacsimClient
import Ports

@testable import Jacsim

private struct HomeTestError: Error, Equatable {}

@Test("miniCardImageLoaded는 index가 아닌 id 기준으로 카드 이미지를 갱신한다")
@MainActor
func miniCardImageLoadedUpdatesById() async {
    let firstID = UUID()
    let secondID = UUID()
    let loadedImage = Data("second-image".utf8)

    var initialState = HomeFeature.State()
    initialState.miniCardDisplayData = [
        .init(id: secondID, title: "B", progress: 0.3, totalDays: 10, completedDays: 3, imageData: nil, isTodayCertified: false),
        .init(id: firstID, title: "A", progress: 0.7, totalDays: 10, completedDays: 7, imageData: nil, isTodayCertified: true)
    ]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(.miniCardImageLoaded(id: firstID, imageData: loadedImage)) {
        $0.miniCardDisplayData[1] = HomeFeature.State.MiniCardDisplayData(
            id: firstID,
            title: "A",
            progress: 0.7,
            totalDays: 10,
            completedDays: 7,
            imageData: loadedImage,
            isTodayCertified: true
        )
    }
}

@Test("miniCardImageLoaded는 존재하지 않는 id 응답을 무시한다")
@MainActor
func miniCardImageLoadedIgnoresUnknownId() async {
    let knownID = UUID()
    let unknownID = UUID()
    let originalImage = Data("original-image".utf8)

    var initialState = HomeFeature.State()
    initialState.miniCardDisplayData = [
        .init(
            id: knownID,
            title: "Known",
            progress: 0.5,
            totalDays: 20,
            completedDays: 10,
            imageData: originalImage,
            isTodayCertified: false
        )
    ]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(.miniCardImageLoaded(id: unknownID, imageData: Data("new".utf8)))
    #expect(store.state.miniCardDisplayData[0].imageData == originalImage)
}

@Test("AllTask 행 탭 delegate를 받으면 상세 화면으로 이동한다")
@MainActor
func homeNavigatesToDetailFromAllTaskDelegate() async {
    let task = makeHomeTestTask(title: "작심")
    var initialState = HomeFeature.State()
    initialState.path.append(.allTasks(AllTaskFeature.State()))
    let allTaskPathID = initialState.path.ids[0]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(
        .path(
            .element(
                id: allTaskPathID,
                action: .allTasks(.delegate(.navigateToDetail(task)))
            )
        )
    ) {
        $0.path.append(.detail(TaskDetailFeature.State(task: task)))
    }
}

@Test("AllTask 빈 상태 CTA delegate를 받으면 홈으로 돌아가 생성 시트를 연다")
@MainActor
func homeOpensChallengeCreateFromAllTaskDelegate() async {
    var initialState = HomeFeature.State()
    initialState.path.append(.allTasks(AllTaskFeature.State()))
    let allTaskPathID = initialState.path.ids[0]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(
        .path(
            .element(
                id: allTaskPathID,
                action: .allTasks(.delegate(.createTaskRequested))
            )
        )
    ) {
        $0.path.removeLast()
        $0.destination = .challengeCreate(ChallengeCreateFeature.State())
    }
}

@Test("설정의 사용법 액션 delegate를 받으면 온보딩 가이드 화면으로 이동한다")
@MainActor
func homeNavigatesToWalkthroughFromSettingDelegate() async {
    var initialState = HomeFeature.State()
    initialState.path.append(.setting(SettingFeature.State()))
    let settingPathID = initialState.path.ids[0]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(
        .path(
            .element(
                id: settingPathID,
                action: .setting(.delegate(.navigateToWalkThrough))
            )
        )
    ) {
        $0.path.append(.walkThrough(WalkThroughFeature.State(fromSetting: true)))
    }
}

@Test("설정의 라이선스 액션 delegate를 받으면 라이선스 화면으로 이동한다")
@MainActor
func homeNavigatesToLicenseFromSettingDelegate() async {
    var initialState = HomeFeature.State()
    initialState.path.append(.setting(SettingFeature.State()))
    let settingPathID = initialState.path.ids[0]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(
        .path(
            .element(
                id: settingPathID,
                action: .setting(.delegate(.navigateToLicence))
            )
        )
    ) {
        $0.path.append(.openSourceLicense(OpenSourceLicenseFeature.State()))
    }
}

@Test("설정의 문의하기 액션은 즉시 안내 토스트를 보여준다")
@MainActor
func homeShowsToastWhenInquiryActionTriggered() async {
    var initialState = HomeFeature.State()
    initialState.path.append(.setting(SettingFeature.State()))
    let settingPathID = initialState.path.ids[0]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    } withDependencies: {
        $0.externalNavigationClient = ExternalNavigationClient(
            openInquiryMail: { true },
            requestReview: { false }
        )
    }

    await store.send(
        .path(
            .element(
                id: settingPathID,
                action: .setting(.delegate(.presentMailCompose))
            )
        )
    ) {
        $0.toastMessage = "문의하기를 시도했어요. 메일 앱이 열리지 않으면 메일 설정을 확인해 주세요"
    }
}

@Test("설정의 리뷰 액션은 즉시 안내 토스트를 보여준다")
@MainActor
func homeShowsToastWhenReviewActionTriggered() async {
    var initialState = HomeFeature.State()
    initialState.path.append(.setting(SettingFeature.State()))
    let settingPathID = initialState.path.ids[0]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    } withDependencies: {
        $0.externalNavigationClient = ExternalNavigationClient(
            openInquiryMail: { false },
            requestReview: { false }
        )
    }

    await store.send(
        .path(
            .element(
                id: settingPathID,
                action: .setting(.delegate(.openReviewURL))
            )
        )
    ) {
        $0.toastMessage = "리뷰 요청을 시도했어요. 의견을 남겨주시면 큰 힘이 돼요"
    }
}

@Test("홈 첫 로드 실패 시 오류 상태로 전환된다")
@MainActor
func homeShowsLoadFailedStateWhenInitialFetchFails() async {
    var initialState = HomeFeature.State()
    initialState.hasStartedNotificationListener = true

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    } withDependencies: {
        $0.taskRepository = TaskRepositoryPort(
            fetchActiveTasks: { throw HomeTestError() },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
    }
    store.exhaustivity = .off

    await store.send(.onAppear) {
        $0.hasStartedNotificationListener = true
        $0.isFetching = true
        $0.isLoading = true
        $0.loadFailed = false
    }
    await store.receive(\.tasksLoadFailed) {
        $0.isLoading = false
        $0.isFetching = false
        $0.loadFailed = true
    }
}

@Test("홈 재시도 성공 시 오류 상태를 해제하고 작심을 다시 구성한다")
@MainActor
func homeRetryClearsLoadFailedAndLoadsTasks() async {
    let task = makeHomeTestTask(title: "매일 산책")

    var initialState = HomeFeature.State()
    initialState.loadFailed = true

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    } withDependencies: {
        $0.taskRepository = TaskRepositoryPort(
            fetchActiveTasks: { [task] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
        $0.imageStore = ImageStorePort(
            saveImage: { _, _ in "" },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
        )
    }
    store.exhaustivity = .off

    await store.send(.refreshTriggered) {
        $0.isRefreshing = true
        $0.loadFailed = false
    }
    await store.receive(\.tasksResponse) {
        $0.tasks = [task]
        $0.activeTasks = [task]
        $0.heroTask = task
        $0.secondaryTasks = []
        $0.miniCardDisplayData = []
        $0.todayFocusState = .pending
        $0.todayPendingCount = 1
        $0.todayCompletedCount = 0
        $0.isLoading = false
        $0.isRefreshing = false
        $0.isFetching = false
        $0.loadFailed = false
    }
    await store.receive(\.heroImageLoaded) {
        $0.heroTaskImageData = nil
    }
}

@Test("tasksResponse는 오늘 미완료 작심을 hero로 선택한다")
@MainActor
func homeSelectsPendingFocusTask() async {
    let today = Calendar.current.startOfDay(for: Date())
    let completed = makeHomeTestTask(
        title: "완료됨",
        startDate: Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today,
        endDate: Calendar.current.date(byAdding: .day, value: 5, to: today) ?? today,
        completedToday: true
    )
    let pending = makeHomeTestTask(
        title: "미완료",
        startDate: Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today,
        endDate: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
    )

    let store = TestStore(initialState: HomeFeature.State()) {
        HomeFeature()
    } withDependencies: {
        $0.imageStore = ImageStorePort(
            saveImage: { _, _ in "" },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
        )
    }
    store.exhaustivity = .off

    await store.send(.tasksResponse([completed, pending])) {
        $0.tasks = [completed, pending]
        $0.activeTasks = [pending, completed]
        $0.heroTask = pending
        $0.secondaryTasks = [completed]
        $0.miniCardDisplayData = [
            .init(
                id: completed.id.rawValue,
                title: "완료됨",
                progress: completed.progress,
                totalDays: completed.dayArray.count,
                completedDays: completed.completedDays,
                imageData: nil,
                isTodayCertified: true
            )
        ]
        $0.todayFocusState = .pending
        $0.todayPendingCount = 1
        $0.todayCompletedCount = 1
        $0.heroTaskImageData = nil
        $0.isLoading = false
        $0.isRefreshing = false
        $0.isFetching = false
        $0.loadFailed = false
    }
}

@Test("tasksResponse는 모든 작심을 끝낸 날에 allDoneToday 상태를 만든다")
@MainActor
func homeBuildsAllDoneTodayState() async {
    let today = Calendar.current.startOfDay(for: Date())
    let doneTask = makeHomeTestTask(
        title: "오늘 끝낸 작심",
        startDate: Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today,
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: today) ?? today,
        completedToday: true
    )

    let store = TestStore(initialState: HomeFeature.State()) {
        HomeFeature()
    } withDependencies: {
        $0.imageStore = ImageStorePort(
            saveImage: { _, _ in "" },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
        )
    }
    store.exhaustivity = .off

    await store.send(.tasksResponse([doneTask])) {
        $0.tasks = [doneTask]
        $0.activeTasks = [doneTask]
        $0.heroTask = doneTask
        $0.secondaryTasks = []
        $0.miniCardDisplayData = []
        $0.todayFocusState = .allDoneToday
        $0.todayPendingCount = 0
        $0.todayCompletedCount = 1
        $0.heroTaskImageData = nil
        $0.isLoading = false
        $0.isRefreshing = false
        $0.isFetching = false
        $0.loadFailed = false
    }
}

@Test("tasksResponse는 다음 단계 준비가 된 작심을 completedStageReady hero로 선택한다")
@MainActor
func homeBuildsCompletedStageReadyState() async {
    let today = Calendar.current.startOfDay(for: Date())
    let completedStageTask = makeHomeTestTask(
        title: "다음 단계 준비",
        startDate: Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today,
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: today) ?? today,
        completedToday: true,
        stageType: .seven,
        stageResult: .success
    )
    let completedTask = makeHomeTestTask(
        title: "오늘 마침",
        startDate: Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today,
        endDate: Calendar.current.date(byAdding: .day, value: 4, to: today) ?? today,
        completedToday: true
    )

    let store = TestStore(initialState: HomeFeature.State()) {
        HomeFeature()
    } withDependencies: {
        $0.imageStore = ImageStorePort(
            saveImage: { _, _ in "" },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
        )
    }
    store.exhaustivity = .off

    await store.send(.tasksResponse([completedTask, completedStageTask])) {
        $0.tasks = [completedTask, completedStageTask]
        $0.activeTasks = [completedStageTask, completedTask]
        $0.heroTask = completedStageTask
        $0.secondaryTasks = [completedTask]
        $0.miniCardDisplayData = [
            .init(
                id: completedTask.id.rawValue,
                title: "오늘 마침",
                progress: completedTask.progress,
                totalDays: completedTask.dayArray.count,
                completedDays: completedTask.completedDays,
                imageData: nil,
                isTodayCertified: true
            )
        ]
        $0.todayFocusState = .completedStageReady
        $0.todayPendingCount = 0
        $0.todayCompletedCount = 2
        $0.heroTaskImageData = nil
        $0.isLoading = false
        $0.isRefreshing = false
        $0.isFetching = false
        $0.loadFailed = false
    }
}

@Test("tasksResponse는 future-start 작심만 있으면 empty 상태를 만든다")
@MainActor
func homeBuildsEmptyStateWhenOnlyFutureTasksExist() async {
    let today = Calendar.current.startOfDay(for: Date())
    let futureTask = makeHomeTestTask(
        title: "미래 작심",
        startDate: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today,
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: today) ?? today
    )

    let store = TestStore(initialState: HomeFeature.State()) {
        HomeFeature()
    } withDependencies: {
        $0.imageStore = ImageStorePort(
            saveImage: { _, _ in "" },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
        )
    }
    store.exhaustivity = .off

    await store.send(.tasksResponse([futureTask])) {
        $0.tasks = [futureTask]
        $0.activeTasks = []
        $0.heroTask = nil
        $0.secondaryTasks = []
        $0.miniCardDisplayData = []
        $0.todayFocusState = .empty
        $0.todayPendingCount = 0
        $0.todayCompletedCount = 0
        $0.heroTaskImageData = nil
        $0.isLoading = false
        $0.isRefreshing = false
        $0.isFetching = false
        $0.loadFailed = false
    }
    await store.receive(\.heroImageLoaded) {
        $0.heroTaskImageData = nil
    }
}

@Test("notificationTaskLoaded가 nil이면 홈 fallback 토스트를 노출한다")
@MainActor
func homeShowsToastWhenNotificationTargetIsMissing() async {
    let store = TestStore(initialState: HomeFeature.State()) {
        HomeFeature()
    }

    await store.send(.notificationTaskLoaded(nil)) {
        $0.toastMessage = "작심을 찾지 못해 홈으로 이동했어요"
    }
}

@Test("Home 카드 탭은 상세 화면으로 이동한다")
@MainActor
func homeRoutesTaskTapToDetail() async {
    let task = makeHomeTestTask(title: "상세 이동")

    let store = TestStore(initialState: HomeFeature.State()) {
        HomeFeature()
    }

    await store.send(.taskTapped(task)) {
        $0.path.append(.detail(TaskDetailFeature.State(task: task)))
    }
}

private func makeHomeTestTask(
    title: String,
    startDate: Date? = nil,
    endDate: Date? = nil,
    completedToday: Bool = false,
    stageType: StageType = .seven,
    stageResult: StageResult = .inProgress
) -> Task {
    let start = startDate ?? Calendar.current.startOfDay(for: Date())
    let end = endDate ?? (Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start)
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: stageType.rawValue,
        startDate: start,
        endDate: end,
        durationDays: stageType.durationDays,
        successDays: 0,
        resultRaw: stageResult.rawValue
    )

    let records: [DailyRecordSnapshot]
    if completedToday {
        records = [
            DailyRecordSnapshot(
                id: UUID(),
                memo: "",
                check: true,
                date: Calendar.current.startOfDay(for: Date()),
                imagePath: nil
            )
        ]
    } else {
        records = []
    }

    return Task(
        id: TaskID(UUID()),
        title: title,
        startDate: start,
        endDate: end,
        alarm: nil,
        isNotificationEnabled: false,
        stages: [stage],
        records: records
    )
}
