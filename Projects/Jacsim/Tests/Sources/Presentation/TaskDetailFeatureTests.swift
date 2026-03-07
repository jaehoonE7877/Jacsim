import Foundation
import Testing
import ComposableArchitecture
import Domain
import UIKit

@testable import Jacsim

private actor UpdateTaskSettingsRecorder {
    struct Call: Equatable {
        let taskID: TaskID
        let title: String
        let durationDays: Int
        let isAlarmEnabled: Bool
        let alarmDate: Date
        let imageByteCount: Int
    }

    private(set) var calls: [Call] = []

    func record(_ input: UpdateTaskSettingsUseCase.Input) {
        let byteCount = input.mainImageData?.count ?? 0
        calls.append(
            Call(
                taskID: input.task.id,
                title: input.title,
                durationDays: input.durationDays,
                isAlarmEnabled: input.isAlarmEnabled,
                alarmDate: input.alarmDate,
                imageByteCount: byteCount
            )
        )
    }

    func callCount() -> Int { calls.count }
    func lastCall() -> Call? { calls.last }
}

@MainActor
@Test("작심 수정 저장은 기존 스테이지 기간을 유지해 updateTaskSettingsUseCase를 호출한다")
func taskDetailEditSaveKeepsCurrentDurationDays() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 1)
    let recorder = UpdateTaskSettingsRecorder()
    let editedAlarmDate = Calendar.current.date(from: DateComponents(hour: 6, minute: 45)) ?? Date()

    var initialState = TaskDetailFeature.State(task: task)
    initialState.editTask = TaskEditFeature.State(task: task)

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    } withDependencies: {
        $0.updateTaskSettingsUseCase = UpdateTaskSettingsUseCase(
            execute: { input in await recorder.record(input) }
        )
    }
    store.exhaustivity = .off

    await store.send(
        .editTask(
            .presented(
                .delegate(.saved("수정 제목", nil, true, editedAlarmDate))
            )
        )
    ) {
        $0.editTask = nil
    }
    await store.finish()

    #expect(await recorder.callCount() == 1)
    let last = await recorder.lastCall()
    #expect(last?.taskID == task.id)
    #expect(last?.title == "수정 제목")
    #expect(last?.durationDays == 7)
    #expect(last?.isAlarmEnabled == true)
    #expect(last?.alarmDate == editedAlarmDate)
    #expect(last?.imageByteCount == 0)
}

@MainActor
@Test("작심 수정 저장에서 이미지가 있으면 use case 입력에 JPEG 데이터가 포함된다")
func taskDetailEditSavePassesImageDataWhenProvided() async {
    let task = makeTaskForDetailTests(durationDays: 15, completedRecords: 0)
    let recorder = UpdateTaskSettingsRecorder()
    let image = makeSolidTestImage()
    let editedAlarmDate = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()

    var initialState = TaskDetailFeature.State(task: task)
    initialState.editTask = TaskEditFeature.State(task: task)

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    } withDependencies: {
        $0.updateTaskSettingsUseCase = UpdateTaskSettingsUseCase(
            execute: { input in await recorder.record(input) }
        )
    }
    store.exhaustivity = .off

    await store.send(
        .editTask(
            .presented(
                .delegate(.saved("이미지 수정", image, false, editedAlarmDate))
            )
        )
    ) {
        $0.editTask = nil
    }
    await store.finish()

    #expect(await recorder.callCount() == 1)
    let last = await recorder.lastCall()
    #expect((last?.imageByteCount ?? 0) > 0)
}

@MainActor
@Test("오늘 인증 버튼은 오늘 인덱스로 인증 화면 이동 delegate를 보낸다")
func taskDetailCertifyTodayRoutesToTodayUpdate() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 0)
    let todayIndex = task.dayArray.firstIndex {
        Calendar.current.isDate($0, inSameDayAs: Date())
    }!

    let store = TestStore(initialState: TaskDetailFeature.State(task: task)) {
        TaskDetailFeature()
    }

    await store.send(.certifyTodayTapped)
    await store.receive(.delegate(.navigateToUpdate(task, todayIndex)))
}

@MainActor
@Test("기록 날짜 탭은 해당 날짜 인덱스로 인증 화면 이동 delegate를 보낸다")
func taskDetailDayTappedRoutesToMatchingUpdateIndex() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 0)
    let targetIndex = 2
    let targetDate = task.dayArray[targetIndex]

    let store = TestStore(initialState: TaskDetailFeature.State(task: task)) {
        TaskDetailFeature()
    }

    await store.send(.dayTapped(targetDate))
    await store.receive(.delegate(.navigateToUpdate(task, targetIndex)))
}

@MainActor
@Test("뒤로 가기 버튼은 이전 화면 이동 delegate를 보낸다")
func taskDetailBackButtonRoutesBack() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 0)

    let store = TestStore(initialState: TaskDetailFeature.State(task: task)) {
        TaskDetailFeature()
    }

    await store.send(.backButtonTapped)
    await store.receive(.delegate(.navigateBack))
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
