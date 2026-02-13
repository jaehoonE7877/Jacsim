import Foundation
import Testing
import ComposableArchitecture
import Domain

@testable import Jacsim

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

private func makeHomeTestTask(title: String) -> Task {
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.seven.rawValue,
        startDate: start,
        endDate: end,
        durationDays: 7,
        successDays: 0,
        resultRaw: StageResult.inProgress.rawValue
    )

    return Task(
        id: TaskID(UUID()),
        title: title,
        startDate: start,
        endDate: end,
        alarm: nil,
        isNotificationEnabled: false,
        stages: [stage],
        records: []
    )
}
