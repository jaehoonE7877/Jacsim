import Foundation
import Testing
import ComposableArchitecture
import Domain
import ExternalInterface
import UIKit

@testable import Jacsim

private actor TaskDetailUpdateRecorder {
    struct UpdateCall: Equatable {
        let taskID: TaskID
        let title: String
        let durationDays: Int
        let isAlarmEnabled: Bool
        let alarmDate: Date
    }

    private(set) var updateCalls: [UpdateCall] = []

    func recordUpdate(
        taskID: TaskID,
        title: String,
        durationDays: Int,
        isAlarmEnabled: Bool,
        alarmDate: Date
    ) {
        updateCalls.append(
            UpdateCall(
                taskID: taskID,
                title: title,
                durationDays: durationDays,
                isAlarmEnabled: isAlarmEnabled,
                alarmDate: alarmDate
            )
        )
    }

    func lastCall() -> UpdateCall? { updateCalls.last }
    func callCount() -> Int { updateCalls.count }
}

private actor TaskDetailImageSaveRecorder {
    struct SaveCall: Equatable {
        let key: String
        let byteCount: Int
    }

    private(set) var saveCalls: [SaveCall] = []
    private(set) var deleteCalls: [String] = []

    func recordSave(key: String, data: Data) {
        saveCalls.append(SaveCall(key: key, byteCount: data.count))
    }

    func recordDelete(key: String) {
        deleteCalls.append(key)
    }

    func callCount() -> Int { saveCalls.count }
    func firstCall() -> SaveCall? { saveCalls.first }
    func deletedKeys() -> [String] { deleteCalls }
}

private actor TaskDetailDeleteRecorder {
    private(set) var deletedTaskIDs: [TaskID] = []
    private(set) var cancelledTaskIDs: [TaskID] = []

    func recordDeleted(_ taskID: TaskID) {
        deletedTaskIDs.append(taskID)
    }

    func recordCancelled(_ taskID: TaskID) {
        cancelledTaskIDs.append(taskID)
    }

    func deletedIDs() -> [TaskID] { deletedTaskIDs }
    func cancelledIDs() -> [TaskID] { cancelledTaskIDs }
}

@MainActor
@Test("작심 수정 저장은 기존 스테이지 기간을 유지해 updateTaskInfo를 호출한다")
func taskDetailEditSaveKeepsCurrentDurationDays() async {
    let task = makeTaskForDetailTests(durationDays: 7, completedRecords: 1)
    let updateRecorder = TaskDetailUpdateRecorder()
    let imageRecorder = TaskDetailImageSaveRecorder()
    let editedAlarmDate = Calendar.current.date(from: DateComponents(hour: 6, minute: 45)) ?? Date()

    var initialState = TaskDetailFeature.State(task: task)
    initialState.editTask = TaskEditFeature.State(task: task)

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    } withDependencies: {
        $0.taskCommandClient = TaskCommandClientPort(
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            updateTaskInfo: { task, title, durationDays, isAlarmEnabled, alarmDate in
                await updateRecorder.recordUpdate(
                    taskID: task.id,
                    title: title,
                    durationDays: durationDays,
                    isAlarmEnabled: isAlarmEnabled,
                    alarmDate: alarmDate
                )
            }
        )
        $0.imageStore = ImageStorePort(
            saveImage: { key, data in
                await imageRecorder.recordSave(key: key, data: data)
                return key
            },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
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

    #expect(await updateRecorder.callCount() == 1)
    let lastCall = await updateRecorder.lastCall()
    #expect(lastCall?.taskID == task.id)
    #expect(lastCall?.title == "수정 제목")
    #expect(lastCall?.durationDays == 7)
    #expect(lastCall?.isAlarmEnabled == true)
    #expect(lastCall?.alarmDate == editedAlarmDate)
    #expect(await imageRecorder.callCount() == 0)
}

@MainActor
@Test("작심 수정 저장에서 이미지가 있으면 대표 이미지 키로 저장한다")
func taskDetailEditSaveStoresImageWhenProvided() async {
    let task = makeTaskForDetailTests(durationDays: 15, completedRecords: 0)
    let updateRecorder = TaskDetailUpdateRecorder()
    let imageRecorder = TaskDetailImageSaveRecorder()
    let image = makeSolidTestImage()
    let editedAlarmDate = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()

    var initialState = TaskDetailFeature.State(task: task)
    initialState.editTask = TaskEditFeature.State(task: task)

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    } withDependencies: {
        $0.taskCommandClient = TaskCommandClientPort(
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            updateTaskInfo: { task, title, durationDays, isAlarmEnabled, alarmDate in
                await updateRecorder.recordUpdate(
                    taskID: task.id,
                    title: title,
                    durationDays: durationDays,
                    isAlarmEnabled: isAlarmEnabled,
                    alarmDate: alarmDate
                )
            }
        )
        $0.imageStore = ImageStorePort(
            saveImage: { key, data in
                await imageRecorder.recordSave(key: key, data: data)
                return key
            },
            loadImage: { _ in nil },
            deleteImage: { _ in },
            imageExists: { _ in false }
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

    #expect(await updateRecorder.callCount() == 1)
    #expect(await imageRecorder.callCount() == 1)
    let firstSave = await imageRecorder.firstCall()
    #expect(firstSave?.key == task.mainImageKey)
    #expect((firstSave?.byteCount ?? 0) > 0)
}

@MainActor
@Test("작심 삭제는 대표 이미지와 기록 이미지를 함께 정리한다")
func taskDetailDeleteFlowDeletesStoredImages() async {
    let task = makeTaskForDetailTests(
        durationDays: 7,
        completedRecords: 3,
        recordImagePaths: ["day-1.jpg", "day-2.jpg", "day-1.jpg"]
    )
    let deleteRecorder = TaskDetailDeleteRecorder()
    let imageRecorder = TaskDetailImageSaveRecorder()

    var initialState = TaskDetailFeature.State(task: task)
    initialState.isDeleteFlowPresented = true
    initialState.deleteFlowStep = .finalConfirmation
    initialState.deleteConfirmCountdown = 0
    initialState.isDeleteConfirmEnabled = true

    let store = TestStore(initialState: initialState) {
        TaskDetailFeature()
    } withDependencies: {
        $0.taskCommandClient = TaskCommandClientPort(
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { taskID in await deleteRecorder.recordDeleted(taskID) },
            updateTaskInfo: { _, _, _, _, _ in }
        )
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { _, _, _ in },
            cancelReminder: { taskID in await deleteRecorder.recordCancelled(taskID) },
            cancelAllReminders: {},
            requestAuthorization: { true }
        )
        $0.imageStore = ImageStorePort(
            saveImage: { key, data in
                await imageRecorder.recordSave(key: key, data: data)
                return key
            },
            loadImage: { _ in nil },
            deleteImage: { key in await imageRecorder.recordDelete(key: key) },
            imageExists: { _ in false }
        )
    }
    store.exhaustivity = .off

    await store.send(.deleteFlowDeleteConfirmed) {
        $0.isDeleteFlowPresented = false
    }
    await store.finish()

    #expect(await deleteRecorder.cancelledIDs() == [task.id])
    #expect(await deleteRecorder.deletedIDs() == [task.id])
    #expect(await imageRecorder.deletedKeys() == [task.mainImageKey, "day-1.jpg", "day-2.jpg"])
}

private func makeTaskForDetailTests(
    durationDays: Int,
    completedRecords: Int,
    recordImagePaths: [String?] = []
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
            imagePath: recordImagePaths.indices.contains(index) ? recordImagePaths[index] : nil
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
