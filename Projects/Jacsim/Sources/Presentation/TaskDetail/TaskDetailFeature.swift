import Foundation
import Domain
import ComposableArchitecture
import ExternalInterface
import UIKit
import DSKit
import Core

@Reducer
public struct TaskDetailFeature {
    public enum DeleteFlowStep: Equatable {
        case firstGuard
        case finalConfirmation
    }

    @ObservableState
    public struct State: Equatable {
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
        public var coverImage: UIImage? = nil

        @Presents public var editTask: TaskEditFeature.State?
        
        public struct DayViewData: Equatable, Identifiable {
            public var id: Date { date }
            let date: Date
            let memo: String
            let image: UIImage?
            let isChecked: Bool
        }
        
        public init(task: Domain.Task) {
            self.task = task
        }
    }

    public enum Action {
        case onAppear
        case loadImages
        case imageLoaded(Date, UIImage?)
        case coverImageLoaded(UIImage?)
        case dayTapped(Date)
        
        case changePhotoButtonTapped
        case notificationSettingsButtonTapped
        case editMemoButtonTapped
        case deleteButtonTapped
        case deleteConfirmed
        case deleteCancelled
        case deleteFlowStarted
        case deleteFlowDismissed
        case deleteFlowProceedToFinal
        case deleteFlowKeepGoing
        case deleteFlowCountdownTicked
        case deleteFlowDeleteConfirmed
        
        case editButtonTapped
        case editTask(PresentationAction<TaskEditFeature.Action>)
        
        case stageResultChecked(StageResult)
        case stagePopupDismissed
        
        case certifyTodayTapped
        case nextStageButtonTapped
        case viewSuccessRecordTapped
        case retryStageButtonTapped
        case keepAsIsButtonTapped
        case viewHistoryButtonTapped
        case scrollToRecordsCompleted
        
        case backButtonTapped

        case delegate(Delegate)
        public enum Delegate {
            case taskDeleted
            case navigateToUpdate(Domain.Task, Int)
            case navigateToPhotoChange(Domain.Task)
            case navigateToNotificationSettings(Domain.Task)
            case navigateToMemoEdit(Domain.Task)
            case navigateBack
        }
    }

    @Dependency(\.taskCommandClient) var taskCommandClient
    @Dependency(\.stageFlowClient) var stageFlowClient
    @Dependency(\.imageStore) var imageStore
    @Dependency(\.notificationScheduler) var notificationScheduler
    @Dependency(\.userSettingsRepository) var userSettingsRepository
    @Dependency(\.challengeStateService) var challengeStateService

    private enum DeleteFlowPolicy {
        static let confirmDelaySeconds = 2
        static let countdownTickNanoseconds: UInt64 = 1_000_000_000
    }

    private enum CancelID {
        case deleteFlowCountdown
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let originalTask = state.task
                let evaluation = challengeStateService.evaluateChallengeState(
                    for: state.task,
                    today: Date()
                )
                if let refreshedStage = evaluation.currentStage,
                   let stageIndex = state.task.stages.firstIndex(where: { $0.id == refreshedStage.id }) {
                    state.task.stages[stageIndex] = refreshedStage
                }
                state.challengeState = evaluation.challengeState
                state.todayStatus = evaluation.todayStatus
                state.currentStage = evaluation.currentStage
                state.stageProgress = evaluation.stageProgress
                state.stageProgressText = evaluation.stageProgressText
                state.remainingSuccessCount = evaluation.remainingSuccessCount
                state.todayMemo = evaluation.todayMemo
                state.dayViewData = evaluation.dayViewData.map {
                    State.DayViewData(date: $0.date, memo: $0.memo, image: nil, isChecked: $0.isChecked)
                }

                var effects: [Effect<Action>] = [.send(.loadImages)]
                if state.task != originalTask {
                    effects.append(
                        .run { [taskCommandClient, task = state.task] _ in
                            do {
                                try await taskCommandClient.updateTask(task)
                            } catch {
                                Logger.certificationFailed(error: error)
                            }
                        }
                    )
                }
                if let result = evaluation.currentStage?.result,
                   result != .inProgress {
                    effects.append(.send(.stageResultChecked(result)))
                }
                return .merge(effects)
                
            case .loadImages:
                return .run { [task = state.task, dayDates = state.dayViewData.map(\.date), imageStore] send in
                    let coverImageData = await imageStore.loadImage(task.mainImageKey)
                    let coverImage = coverImageData.flatMap { UIImage(data: $0) }
                    await send(.coverImageLoaded(coverImage))

                    for date in dayDates {
                        guard let key = task.imageKey(for: task.dayArray.firstIndex(where: { $0 == date }) ?? 0) else { continue }
                        let imageData = await imageStore.loadImage(key)
                        let image = imageData.flatMap { UIImage(data: $0) }
                        await send(.imageLoaded(date, image))
                    }
                }
                
            case let .coverImageLoaded(image):
                state.coverImage = image
                return .none

            case let .imageLoaded(date, image):
                if let index = state.dayViewData.firstIndex(where: { $0.date == date }) {
                    state.dayViewData[index] = State.DayViewData(
                        date: date,
                        memo: state.dayViewData[index].memo,
                        image: image,
                        isChecked: state.dayViewData[index].isChecked
                    )
                }
                return .none
                
            case .changePhotoButtonTapped:
                state.editTask = TaskEditFeature.State(task: state.task)
                return .none
                
            case .notificationSettingsButtonTapped:
                state.editTask = TaskEditFeature.State(task: state.task)
                return .none
                
            case .editMemoButtonTapped:
                let today = Calendar.current.startOfDay(for: Date())
                if let index = state.task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                    return .send(.delegate(.navigateToUpdate(state.task, index)))
                }
                return .none

            case .backButtonTapped:
                return .send(.delegate(.navigateBack))

            case .deleteButtonTapped:
                return .send(.deleteFlowStarted)
                
            case .deleteConfirmed:
                state.isDeleteConfirmationPresented = false
                state.isDeleteFlowPresented = false
                let task = state.task
                let taskId = task.id
                return .merge(
                    .cancel(id: CancelID.deleteFlowCountdown),
                    .run { [taskCommandClient, notificationScheduler, imageStore, task] send in
                        await notificationScheduler.cancelReminder(taskId)
                        do {
                            try await taskCommandClient.deleteTask(taskId)
                            await deleteStoredImages(for: task, imageStore: imageStore)
                        } catch {
                            Logger.certificationFailed(error: error)
                        }
                        await send(.delegate(.taskDeleted))
                    }
                )
                
            case .deleteCancelled:
                state.isDeleteConfirmationPresented = false
                state.isDeleteFlowPresented = false
                state.deleteFlowStep = .firstGuard
                state.deleteConfirmCountdown = DeleteFlowPolicy.confirmDelaySeconds
                state.isDeleteConfirmEnabled = false
                return .cancel(id: CancelID.deleteFlowCountdown)

            case .deleteFlowStarted:
                state.isDeleteFlowPresented = true
                state.deleteFlowStep = .firstGuard
                state.deleteConfirmCountdown = DeleteFlowPolicy.confirmDelaySeconds
                state.isDeleteConfirmEnabled = false
                return .cancel(id: CancelID.deleteFlowCountdown)

            case .deleteFlowDismissed, .deleteFlowKeepGoing:
                state.isDeleteFlowPresented = false
                state.deleteFlowStep = .firstGuard
                state.deleteConfirmCountdown = DeleteFlowPolicy.confirmDelaySeconds
                state.isDeleteConfirmEnabled = false
                return .cancel(id: CancelID.deleteFlowCountdown)

            case .deleteFlowProceedToFinal:
                state.deleteFlowStep = .finalConfirmation
                state.deleteConfirmCountdown = DeleteFlowPolicy.confirmDelaySeconds
                state.isDeleteConfirmEnabled = false
                return .run { send in
                    for _ in 0..<DeleteFlowPolicy.confirmDelaySeconds {
                        do {
                            try await _Concurrency.Task.sleep(
                                nanoseconds: DeleteFlowPolicy.countdownTickNanoseconds
                            )
                        } catch is CancellationError {
                            return
                        } catch {
                            return
                        }
                        await send(.deleteFlowCountdownTicked)
                    }
                }
                .cancellable(id: CancelID.deleteFlowCountdown, cancelInFlight: true)

            case .deleteFlowCountdownTicked:
                guard state.deleteFlowStep == .finalConfirmation else { return .none }
                guard state.deleteConfirmCountdown > 0 else {
                    state.isDeleteConfirmEnabled = true
                    return .none
                }
                state.deleteConfirmCountdown -= 1
                if state.deleteConfirmCountdown <= 0 {
                    state.isDeleteConfirmEnabled = true
                }
                return .none

            case .deleteFlowDeleteConfirmed:
                guard state.isDeleteConfirmEnabled else { return .none }
                state.isDeleteFlowPresented = false
                state.isDeleteConfirmationPresented = false
                let task = state.task
                let taskId = task.id
                return .merge(
                    .cancel(id: CancelID.deleteFlowCountdown),
                    .run { [taskCommandClient, notificationScheduler, imageStore, task] send in
                        await notificationScheduler.cancelReminder(taskId)
                        do {
                            try await taskCommandClient.deleteTask(taskId)
                            await deleteStoredImages(for: task, imageStore: imageStore)
                        } catch {
                            Logger.certificationFailed(error: error)
                        }
                        await send(.delegate(.taskDeleted))
                    }
                )
                
            case let .dayTapped(date):
                if let index = state.task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                    return .send(.delegate(.navigateToUpdate(state.task, index)))
                }
                return .none

            case .editButtonTapped:
                state.editTask = TaskEditFeature.State(task: state.task)
                return .none

            case let .editTask(.presented(.delegate(.saved(title, image, isAlarmEnabled, alarmDate)))):
                let task = state.task
                let durationDays = task.currentStage?.durationDays ?? task.stages.last?.durationDays ?? 3
                state.editTask = nil
                return .run { [taskCommandClient, imageStore, notificationScheduler, userSettingsRepository, task, durationDays] send in
                    await taskCommandClient.updateTaskInfo(task, title, durationDays, isAlarmEnabled, alarmDate)
                    if let image {
                        do {
                            let data = try makeImageStoreInputData(from: image)
                            _ = try await imageStore.saveImage(task.mainImageKey, data)
                        } catch {
                            Logger.certificationFailed(error: error)
                        }
                    }
                    let isGlobalNotificationEnabled = await userSettingsRepository.isNotificationEnabled()
                    let reminders = await userSettingsRepository.getAllReminders()
                    let reminderUseCase = ReminderSchedulingUseCase()
                    await reminderUseCase.syncGlobalReminders(
                        isEnabled: isGlobalNotificationEnabled,
                        reminders: reminders,
                        notificationScheduler: notificationScheduler
                    )
                    await send(.onAppear)
                }

            case .editTask(.presented(.delegate(.cancelled))):
                state.editTask = nil
                return .none

            case .editTask(.dismiss):
                state.editTask = nil
                return .none

            case .editTask:
                return .none

            case let .stageResultChecked(result):
                if result != .inProgress {
                    state.stagePopupResult = result
                    state.isStagePopupPresented = true
                }
                return .none

            case .stagePopupDismissed:
                state.isStagePopupPresented = false
                return .none

            case .certifyTodayTapped:
                let today = Calendar.current.startOfDay(for: Date())
                if let index = state.task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                    return .send(.delegate(.navigateToUpdate(state.task, index)))
                }
                return .none

            case .nextStageButtonTapped:
                let taskId = state.task.id
                return .run { [stageFlowClient, notificationScheduler, userSettingsRepository] send in
                    await stageFlowClient.createNextStage(taskId)
                    let isGlobalNotificationEnabled = await userSettingsRepository.isNotificationEnabled()
                    let reminders = await userSettingsRepository.getAllReminders()
                    let reminderUseCase = ReminderSchedulingUseCase()
                    await reminderUseCase.syncGlobalReminders(
                        isEnabled: isGlobalNotificationEnabled,
                        reminders: reminders,
                        notificationScheduler: notificationScheduler
                    )
                    await send(.stagePopupDismissed)
                    await send(.onAppear)
                }

            case .viewSuccessRecordTapped:
                state.isStagePopupPresented = true
                state.stagePopupResult = .success
                return .none

            case .retryStageButtonTapped:
                return .run { [stageFlowClient, notificationScheduler, userSettingsRepository, taskId = state.task.id] send in
                    await stageFlowClient.resetStageRecords(taskId)
                    let isGlobalNotificationEnabled = await userSettingsRepository.isNotificationEnabled()
                    let reminders = await userSettingsRepository.getAllReminders()
                    let reminderUseCase = ReminderSchedulingUseCase()
                    await reminderUseCase.syncGlobalReminders(
                        isEnabled: isGlobalNotificationEnabled,
                        reminders: reminders,
                        notificationScheduler: notificationScheduler
                    )
                    await send(.onAppear)
                }

            case .keepAsIsButtonTapped:
                return .send(.delegate(.navigateBack))

            case .viewHistoryButtonTapped:
                state.shouldScrollToRecords = true
                return .none

            case .scrollToRecordsCompleted:
                state.shouldScrollToRecords = false
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$editTask, action: \.editTask) {
            TaskEditFeature()
        }
    }
}

private func deleteStoredImages(for task: Domain.Task, imageStore: ImageStorePort) async {
    let imageKeys = [task.mainImageKey] + task.records.compactMap(\.imagePath)
    var deletedKeys = Set<String>()

    for key in imageKeys where deletedKeys.insert(key).inserted {
        await imageStore.deleteImage(key)
    }
}
