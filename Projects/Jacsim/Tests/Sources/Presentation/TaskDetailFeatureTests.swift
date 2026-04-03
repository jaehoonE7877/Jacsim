import Foundation
import Testing
import ComposableArchitecture
import Domain
import JacsimClient
import Ports
import UIKit

@testable import Jacsim

@MainActor
@Test("작심 수정 저장 delegate는 상세 상태의 제목과 알림 값을 즉시 갱신한다")
func taskDetailEditSaveUpdatesLocalTaskState() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 1)
    let editedAlarmDate = Calendar.current.date(from: DateComponents(hour: 6, minute: 45)) ?? Date()

    var initialState = TaskDetailFeature.State(task: task)
    initialState.editTask = TaskEditFeature.State(task: task)

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    }

    await store.send(
        .editTask(
            .presented(
                .delegate(.saved("수정 제목", nil, true, editedAlarmDate))
            )
        )
    ) {
        $0.editTask = nil
        $0.task.title = "수정 제목"
        $0.task.isNotificationEnabled = true
        $0.task.alarm = editedAlarmDate
    }
}

@MainActor
@Test("작심 수정 저장 delegate는 선택한 커버 이미지를 상세 상태에 반영한다")
func taskDetailEditSaveUpdatesCoverImageWhenProvided() async {
    let task = makeTaskForDetailTests(durationDays: 15, completedRecords: 0)
    let image = makeSolidTestImage()
    let editedAlarmDate = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()

    var initialState = TaskDetailFeature.State(task: task)
    initialState.editTask = TaskEditFeature.State(task: task)

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    }

    await store.send(
        .editTask(
            .presented(
                .delegate(.saved("이미지 수정", image, false, editedAlarmDate))
            )
        )
    ) {
        $0.editTask = nil
        $0.task.title = "이미지 수정"
        $0.task.isNotificationEnabled = false
        $0.task.alarm = nil
        $0.coverImage = image
    }
}

@MainActor
@Test("성공 기록 보기 액션은 기록 목록으로 스크롤하도록 상태를 갱신한다")
func taskDetailViewSuccessRecordRequestsScrollToRecords() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 3)
    var initialState = TaskDetailFeature.State(task: task)
    initialState.isStagePopupPresented = true
    initialState.stagePopupResult = .success

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    }

    await store.send(.viewSuccessRecordTapped) {
        $0.isStagePopupPresented = false
        $0.shouldScrollToRecords = true
    }

    await store.send(.scrollToRecordsCompleted) {
        $0.shouldScrollToRecords = false
    }
}

@MainActor
@Test("onAppear는 summary usecase 결과를 상세 상태에 반영한다")
func taskDetailOnAppearAppliesSummaryUseCaseOutput() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 1)
    let summary = TaskReadModelQueries.live().taskDetail(task: task, referenceDate: Date())

    let store = TestStore(initialState: TaskDetailFeature.State(task: task)) {
        TaskDetailFeature()
    } withDependencies: {
        $0.imageStore = ImageStorePort(
            saveImage: { _, _ in "" },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
        )
    }
    store.exhaustivity = .off

    await store.send(.onAppear) {
        $0.challengeState = summary.evaluation.challengeState
        $0.todayStatus = summary.evaluation.todayStatus
        $0.currentStage = summary.evaluation.currentStage
        $0.stageProgress = summary.evaluation.stageProgress
        $0.stageProgressText = summary.evaluation.stageProgressText
        $0.remainingSuccessCount = summary.evaluation.remainingSuccessCount
        $0.todayMemo = summary.evaluation.todayMemo
        $0.dayViewData = summary.evaluation.dayViewData.map {
            TaskDetailFeature.State.DayViewData(
                date: $0.date,
                memo: $0.memo,
                image: nil,
                isChecked: $0.isChecked
            )
        }
    }
}

@MainActor
@Test("삭제 실패 시 상세 화면은 유지되고 실패 alert만 표시한다")
func taskDetailDeleteFailureShowsAlertWithoutNavigatingAway() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 1)
    var initialState = TaskDetailFeature.State(task: task)
    initialState.isDeleteConfirmationPresented = true

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    } withDependencies: {
        $0.deleteTaskUseCase = DeleteTaskUseCase(
            execute: { _ in throw DetailDeleteFailure.failed }
        )
    }

    await store.send(.deleteConfirmed) {
        $0.isDeleteConfirmationPresented = false
    }
    await store.receive(\.deleteTaskFailed) {
        $0.deleteFailureAlert = AlertState {
            TextState("삭제하지 못했어요")
        } actions: {
            ButtonState(action: .dismiss) {
                TextState("확인")
            }
        } message: {
            TextState("잠시 후 다시 시도해 주세요.")
        }
    }
}

private func makeTaskForDetailTests(
    durationDays: Int,
    completedRecords: Int
) -> Task {
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: max(durationDays - 1, 0), to: start) ?? start

    let stageTypeRaw: Int
    switch durationDays {
    case 3:
        stageTypeRaw = StageType.three.rawValue
    case 15:
        stageTypeRaw = StageType.fifteen.rawValue
    case 30:
        stageTypeRaw = StageType.thirty.rawValue
    default:
        stageTypeRaw = StageType.seven.rawValue
    }

    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: stageTypeRaw,
        startDate: start,
        endDate: end,
        durationDays: durationDays,
        successDays: 0,
        resultRaw: StageResult.inProgress.rawValue
    )

    let records: [DailyRecordSnapshot] = (0..<completedRecords).map { index in
        let date = Calendar.current.date(byAdding: .day, value: index, to: start) ?? start
        return DailyRecordSnapshot(
            id: UUID(),
            memo: "",
            check: true,
            date: date,
            imagePath: nil
        )
    }

    return Task(
        id: TaskID(UUID()),
        title: "기존 작심",
        startDate: start,
        endDate: end,
        alarm: nil,
        isNotificationEnabled: false,
        stages: [stage],
        records: records
    )
}

private func makeSolidTestImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12))
    return renderer.image { context in
        UIColor.systemOrange.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 12, height: 12))
    }
}

private enum DetailDeleteFailure: Error {
    case failed
}
