import Testing

@testable import Jacsim

@Test("pending 1개 상태는 단수형 메타와 안내 문구를 만든다")
func homeSummaryPresentationBuildsSingularPendingCopy() {
    let presentation = HomeSummaryCardPresentation(
        todayFocusState: .pending,
        pendingCount: 1,
        completedCount: 0,
        overallProgressText: "21%",
        isStale: false
    )

    #expect(presentation.headerMeta == "오늘 마지막 작심 1개")
    #expect(presentation.primaryValue == "1개")
    #expect(presentation.primarySupport == "오늘 마지막으로 확인할 작심이 하나 남아 있어요")
    #expect(presentation.primaryTone == .brand)
}

@Test("pending 2개 이상 상태는 복수형 메타와 진행 안내 문구를 만든다")
func homeSummaryPresentationBuildsPluralPendingCopy() {
    let presentation = HomeSummaryCardPresentation(
        todayFocusState: .pending,
        pendingCount: 2,
        completedCount: 1,
        overallProgressText: "68%",
        isStale: false
    )

    #expect(presentation.headerMeta == "남은 작심 2개")
    #expect(presentation.primarySupport == "오늘 인증 전인 작심이 2개 남아 있어요")
    #expect(presentation.progressTitle == "진행률")
    #expect(presentation.completionTitle == "오늘 인증")
}

@Test("empty 상태는 비어 있는 포커스용 메타와 중립 톤을 만든다")
func homeSummaryPresentationBuildsEmptyCopy() {
    let presentation = HomeSummaryCardPresentation(
        todayFocusState: .empty,
        pendingCount: 0,
        completedCount: 0,
        overallProgressText: "0%",
        isStale: false
    )

    #expect(presentation.headerMeta == "오늘 이어갈 작심이 아직 없어요")
    #expect(presentation.primarySupport == "새 작심을 만들면 오늘 포커스가 바로 채워집니다")
    #expect(presentation.primaryTone == .neutral)
}

@Test("stale 상태는 상태별 문구 대신 마지막 동기화 안내를 우선한다")
func homeSummaryPresentationPrioritizesStaleCopy() {
    let presentation = HomeSummaryCardPresentation(
        todayFocusState: .allDoneToday,
        pendingCount: 0,
        completedCount: 3,
        overallProgressText: "100%",
        isStale: true
    )

    #expect(presentation.headerMeta == "연결이 안정되면 최신 상태로 다시 바뀝니다")
    #expect(presentation.primarySupport == "현재 보이는 수치는 마지막으로 불러온 기록 기준입니다")
    #expect(presentation.primaryTone == .positive)
}
