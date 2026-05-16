import Core
import Domain
import DSKit
import ExternalInterface
import Foundation
import Observation
import UIKit

@MainActor
@Observable
public final class TaskDetailModel {
    public enum DeleteFlowStep: Equatable {
        case firstGuard
        case finalConfirmation
    }

    public struct DayViewData: Equatable, Identifiable {
        public var id: Date { date }
        let date: Date
        let memo: String
        let image: UIImage?
        let isChecked: Bool
    }

    public var task: Domain.Task
    public var dayViewData: [DayViewData] = []
    public var remainingSuccessCount: Int = 0
    public var isStagePopupPresented: Bool = false
    public var stagePopupResult: StageResult = .inProgress
    public var challengeState: ChallengeDetailState = .stagePending
    public var todayStatus: TodayStatus = .notCertified
    public var currentStage: StageSnapshot?
    public var stageProgress: Double = 0
    public var stageProgressText: String = "0/7"
    public var isDeleteConfirmationPresented: Bool = false
    public var isDeleteFlowPresented: Bool = false
    public var deleteFlowStep: DeleteFlowStep = .firstGuard
    public var deleteConfirmCountdown: Int = DeleteFlowPolicy.confirmDelaySeconds
    public var isDeleteConfirmEnabled: Bool = false
    public var todayMemo: String = ""
    public var shouldScrollToRecords: Bool = false
    public var coverImage: UIImage?
    public var editTask: TaskEditModel?
    public var isVisibilitySelectorPresented: Bool = false

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private let onTaskDeleted: () -> Void
    @ObservationIgnored private let onNavigateToUpdate: (Domain.Task, Int) -> Void
    @ObservationIgnored private let onNavigateBack: () -> Void
    @ObservationIgnored private var imageLoadTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var updateTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var deleteTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var deleteCountdownTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var stageTask: _Concurrency.Task<Void, Never>?

    private enum DeleteFlowPolicy {
        static let confirmDelaySeconds = 2
        static let countdownTickNanoseconds: UInt64 = 1_000_000_000
    }

    public init(
        task: Domain.Task,
        dependencies: JacsimDependencies,
        shouldScrollToRecords: Bool = false,
        onTaskDeleted: @escaping () -> Void = {},
        onNavigateToUpdate: @escaping (Domain.Task, Int) -> Void = { _, _ in },
        onNavigateBack: @escaping () -> Void = {}
    ) {
        self.task = task
        self.dependencies = dependencies
        self.shouldScrollToRecords = shouldScrollToRecords
        self.onTaskDeleted = onTaskDeleted
        self.onNavigateToUpdate = onNavigateToUpdate
        self.onNavigateBack = onNavigateBack
    }

    deinit {
        imageLoadTask?.cancel()
        updateTask?.cancel()
        deleteTask?.cancel()
        deleteCountdownTask?.cancel()
        stageTask?.cancel()
    }

    public func onAppear() {
        let originalTask = task
        let evaluation = dependencies.challengeStateService.evaluateChallengeState(
            for: task,
            today: Date()
        )
        if let refreshedStage = evaluation.currentStage,
           let stageIndex = task.stages.firstIndex(where: { $0.id == refreshedStage.id }) {
            task.stages[stageIndex] = refreshedStage
        }
        challengeState = evaluation.challengeState
        todayStatus = evaluation.todayStatus
        currentStage = evaluation.currentStage
        stageProgress = evaluation.stageProgress
        stageProgressText = evaluation.stageProgressText
        remainingSuccessCount = evaluation.remainingSuccessCount
        todayMemo = evaluation.todayMemo
        dayViewData = evaluation.dayViewData.map {
            DayViewData(date: $0.date, memo: $0.memo, image: nil, isChecked: $0.isChecked)
        }

        loadImages()

        if task != originalTask {
            updateTask?.cancel()
            updateTask = _Concurrency.Task { [dependencies, task] in
                do {
                    try await dependencies.taskCommandClient.updateTask(task)
                } catch {
                    Logger.certificationFailed(error: error)
                }
            }
        }

        if let result = evaluation.currentStage?.result,
           result != .inProgress {
            stageResultChecked(result)
        }
    }

    public func loadImages() {
        let task = task
        let dayDates = dayViewData.map(\.date)
        imageLoadTask?.cancel()
        imageLoadTask = _Concurrency.Task { [dependencies] in
            let coverImageData = await dependencies.imageStore.loadImage(task.mainImageKey)
            let coverImage = coverImageData.flatMap { UIImage(data: $0) }
            coverImageLoaded(coverImage)

            for date in dayDates {
                guard let index = task.dayArray.firstIndex(where: { $0 == date }),
                      let key = task.imageKey(for: index) else { continue }
                let imageData = await dependencies.imageStore.loadImage(key)
                let image = imageData.flatMap { UIImage(data: $0) }
                imageLoaded(date, image)
            }
        }
    }

    public func changePhotoButtonTapped() {
        presentEditTask()
    }

    public func notificationSettingsButtonTapped() {
        presentEditTask()
    }

    public func visibilityButtonTapped() {
        isVisibilitySelectorPresented = true
    }

    public func visibilitySelected(_ visibility: TaskVisibility) {
        let previousVisibility = task.visibility
        task.visibility = visibility
        isVisibilitySelectorPresented = false
        updateTask?.cancel()
        updateTask = _Concurrency.Task { [dependencies, taskId = task.id] in
            do {
                try await dependencies.taskCommandClient.updateVisibility(taskId, visibility)
            } catch {
                Logger.certificationFailed(error: error)
                task.visibility = previousVisibility
            }
        }
    }

    public func visibilitySelectionDismissed() {
        isVisibilitySelectorPresented = false
    }

    public func editMemoButtonTapped() {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            onNavigateToUpdate(task, index)
        }
    }

    public func backButtonTapped() {
        onNavigateBack()
    }

    public func deleteButtonTapped() {
        deleteFlowStarted()
    }

    public func deleteConfirmed() {
        isDeleteConfirmationPresented = false
        isDeleteFlowPresented = false
        performDelete()
    }

    public func deleteCancelled() {
        resetDeleteFlow()
        deleteCountdownTask?.cancel()
    }

    public func deleteFlowStarted() {
        isDeleteFlowPresented = true
        deleteFlowStep = .firstGuard
        deleteConfirmCountdown = DeleteFlowPolicy.confirmDelaySeconds
        isDeleteConfirmEnabled = false
        deleteCountdownTask?.cancel()
    }

    public func deleteFlowDismissed() {
        resetDeleteFlow()
        deleteCountdownTask?.cancel()
    }

    public func deleteFlowProceedToFinal() {
        deleteFlowStep = .finalConfirmation
        deleteConfirmCountdown = DeleteFlowPolicy.confirmDelaySeconds
        isDeleteConfirmEnabled = false
        deleteCountdownTask?.cancel()
        deleteCountdownTask = _Concurrency.Task {
            for _ in 0..<DeleteFlowPolicy.confirmDelaySeconds {
                do {
                    try await _Concurrency.Task.sleep(nanoseconds: DeleteFlowPolicy.countdownTickNanoseconds)
                } catch {
                    return
                }
                deleteFlowCountdownTicked()
            }
        }
    }

    public func deleteFlowKeepGoing() {
        resetDeleteFlow()
        deleteCountdownTask?.cancel()
    }

    public func deleteFlowDeleteConfirmed() {
        guard isDeleteConfirmEnabled else { return }
        isDeleteFlowPresented = false
        isDeleteConfirmationPresented = false
        performDelete()
    }

    public func dayTapped(_ date: Date) {
        if let index = task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
            onNavigateToUpdate(task, index)
        }
    }

    public func editButtonTapped() {
        presentEditTask()
    }

    public func dismissEditTask() {
        editTask = nil
    }

    public func stageResultChecked(_ result: StageResult) {
        if result != .inProgress {
            stagePopupResult = result
            isStagePopupPresented = true
        }
    }

    public func stagePopupDismissed() {
        isStagePopupPresented = false
    }

    public func certifyTodayTapped() {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            onNavigateToUpdate(task, index)
        }
    }

    public func nextStageButtonTapped() {
        let taskId = task.id
        stageTask?.cancel()
        stageTask = _Concurrency.Task { [dependencies] in
            await dependencies.stageFlowClient.createNextStage(taskId)
            await syncGlobalReminders(dependencies: dependencies)
            stagePopupDismissed()
            onAppear()
        }
    }

    public func viewSuccessRecordTapped() {
        isStagePopupPresented = true
        stagePopupResult = .success
    }

    public func retryStageButtonTapped() {
        let taskId = task.id
        stageTask?.cancel()
        stageTask = _Concurrency.Task { [dependencies] in
            await dependencies.stageFlowClient.resetStageRecords(taskId)
            await syncGlobalReminders(dependencies: dependencies)
            onAppear()
        }
    }

    public func keepAsIsButtonTapped() {
        onNavigateBack()
    }

    public func viewHistoryButtonTapped() {
        shouldScrollToRecords = true
    }

    public func scrollToRecordsCompleted() {
        shouldScrollToRecords = false
    }

    private func coverImageLoaded(_ image: UIImage?) {
        coverImage = image
    }

    private func imageLoaded(_ date: Date, _ image: UIImage?) {
        if let index = dayViewData.firstIndex(where: { $0.date == date }) {
            let currentData = dayViewData[index]
            dayViewData[index] = DayViewData(
                date: date,
                memo: currentData.memo,
                image: image,
                isChecked: currentData.isChecked
            )
        }
    }

    private func deleteFlowCountdownTicked() {
        guard deleteFlowStep == .finalConfirmation else { return }
        guard deleteConfirmCountdown > 0 else {
            isDeleteConfirmEnabled = true
            return
        }
        deleteConfirmCountdown -= 1
        if deleteConfirmCountdown <= 0 {
            isDeleteConfirmEnabled = true
        }
    }

    private func performDelete() {
        let task = task
        let taskId = task.id
        deleteCountdownTask?.cancel()
        deleteTask?.cancel()
        deleteTask = _Concurrency.Task { [dependencies] in
            await dependencies.notificationScheduler.cancelReminder(taskId)
            do {
                try await dependencies.taskCommandClient.deleteTask(taskId)
                await deleteStoredImages(for: task, imageStore: dependencies.imageStore)
            } catch {
                Logger.certificationFailed(error: error)
            }
            onTaskDeleted()
        }
    }

    private func resetDeleteFlow() {
        isDeleteFlowPresented = false
        deleteFlowStep = .firstGuard
        deleteConfirmCountdown = DeleteFlowPolicy.confirmDelaySeconds
        isDeleteConfirmEnabled = false
    }

    private func presentEditTask() {
        editTask = TaskEditModel(
            task: task,
            dependencies: dependencies,
            onSaved: { [weak self] title, image, isAlarmEnabled, alarmDate in
                self?.editTaskSaved(
                    title: title,
                    image: image,
                    isAlarmEnabled: isAlarmEnabled,
                    alarmDate: alarmDate
                )
            },
            onCancelled: { [weak self] in
                self?.editTask = nil
            }
        )
    }

    private func editTaskSaved(
        title: String,
        image: UIImage?,
        isAlarmEnabled: Bool,
        alarmDate: Date
    ) {
        let task = task
        let durationDays = task.currentStage?.durationDays ?? task.stages.last?.durationDays ?? 3
        editTask = nil
        updateTask?.cancel()
        updateTask = _Concurrency.Task { [dependencies] in
            await dependencies.taskCommandClient.updateTaskInfo(
                task,
                title,
                durationDays,
                isAlarmEnabled,
                alarmDate
            )
            if let image {
                do {
                    let data = try makeImageStoreInputData(from: image)
                    _ = try await dependencies.imageStore.saveImage(task.mainImageKey, data)
                } catch {
                    Logger.certificationFailed(error: error)
                }
            }
            await syncGlobalReminders(dependencies: dependencies)
            onAppear()
        }
    }
}

private func syncGlobalReminders(dependencies: JacsimDependencies) async {
    let isGlobalNotificationEnabled = await dependencies.userSettingsRepository.isNotificationEnabled()
    let reminders = await dependencies.userSettingsRepository.getAllReminders()
    let reminderUseCase = ReminderSchedulingUseCase()
    await reminderUseCase.syncGlobalReminders(
        isEnabled: isGlobalNotificationEnabled,
        reminders: reminders,
        notificationScheduler: dependencies.notificationScheduler
    )
}

private func deleteStoredImages(for task: Domain.Task, imageStore: ImageStorePort) async {
    let imageKeys = [task.mainImageKey] + task.records.compactMap(\.imagePath)
    var deletedKeys = Set<String>()

    for key in imageKeys where deletedKeys.insert(key).inserted {
        await imageStore.deleteImage(key)
    }
}
