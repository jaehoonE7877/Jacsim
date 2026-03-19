import Foundation
import Domain
import ComposableArchitecture
import UIKit
import DesignSystem
import JacsimClient
import Shared

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
        @Presents public var deleteFailureAlert: AlertState<Action.DeleteFailureAlert>?
        
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
        case deleteTaskSucceeded
        case deleteTaskFailed
        case deleteFailureAlert(PresentationAction<DeleteFailureAlert>)
        
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

        public enum DeleteFailureAlert: Equatable {
            case dismiss
        }
    }

    @Dependency(\.deleteTaskUseCase) var deleteTaskUseCase
    @Dependency(\.loadImageUseCase) var loadImageUseCase
    @Dependency(\.taskDetailSummaryUseCase) var taskDetailSummaryUseCase
    @Dependency(\.stageProgressionUseCase) var stageProgressionUseCase

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
                let summary = taskDetailSummaryUseCase.execute(
                    .init(task: state.task, referenceDate: Date())
                )
                state.challengeState = summary.challengeState
                state.todayStatus = summary.todayStatus
                state.currentStage = summary.currentStage
                state.stageProgress = summary.stageProgress
                state.stageProgressText = summary.stageProgressText
                state.remainingSuccessCount = summary.remainingSuccessCount
                state.todayMemo = summary.todayMemo
                state.dayViewData = summary.dayViewData.map {
                    State.DayViewData(date: $0.date, memo: $0.memo, image: nil, isChecked: $0.isChecked)
                }
                return .merge(
                    .send(.loadImages),
                    .send(.stageResultChecked(summary.stageResult))
                )
                
            case .loadImages:
                return .run { [task = state.task, dayDates = state.dayViewData.map(\.date), loadImageUseCase] send in
                    let coverImageData = await loadImageUseCase.loadImage(task.mainImageKey)
                    let coverImage = coverImageData.flatMap { UIImage(data: $0) }
                    await send(.coverImageLoaded(coverImage))

                    for date in dayDates {
                        guard let key = task.imageKey(for: task.dayArray.firstIndex(where: { $0 == date }) ?? 0) else { continue }
                        let imageData = await loadImageUseCase.loadImage(key)
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
                state.isDeleteConfirmationPresented = true
                return .none
                
            case .deleteConfirmed:
                state.isDeleteConfirmationPresented = false
                let taskId = state.task.id
                return .merge(
                    .cancel(id: CancelID.deleteFlowCountdown),
                    deleteTaskEffect(taskId: taskId)
                )
                
            case .deleteCancelled:
                resetDeleteFlowState(&state)
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
                let taskId = state.task.id
                return .merge(
                    .cancel(id: CancelID.deleteFlowCountdown),
                    deleteTaskEffect(taskId: taskId)
                )

            case .deleteTaskSucceeded:
                resetDeleteFlowState(&state)
                return .send(.delegate(.taskDeleted))

            case .deleteTaskFailed:
                resetDeleteFlowState(&state)
                state.deleteFailureAlert = AlertState {
                    TextState("삭제하지 못했어요")
                } actions: {
                    ButtonState(action: .dismiss) {
                        TextState("확인")
                    }
                } message: {
                    TextState("잠시 후 다시 시도해 주세요.")
                }
                return .none

            case .deleteFailureAlert:
                return .none
                
            case let .dayTapped(date):
                if let index = state.task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                    return .send(.delegate(.navigateToUpdate(state.task, index)))
                }
                return .none

            case .editButtonTapped:
                state.editTask = TaskEditFeature.State(task: state.task)
                return .none

            case let .editTask(.presented(.delegate(.saved(title, image, isAlarmEnabled, alarmDate)))):
                state.editTask = nil
                state.task.title = title
                state.task.isNotificationEnabled = isAlarmEnabled
                state.task.alarm = isAlarmEnabled ? alarmDate : nil
                if let image {
                    state.coverImage = image
                }
                return .none

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
                return .run { [stageProgressionUseCase] send in
                    do {
                        try await stageProgressionUseCase.createNextStage(for: taskId)
                    } catch {
                        Logger.certificationFailed(error: error)
                    }
                    await send(.stagePopupDismissed)
                    await send(.onAppear)
                }

            case .viewSuccessRecordTapped:
                state.isStagePopupPresented = false
                state.shouldScrollToRecords = true
                return .none

            case .retryStageButtonTapped:
                return .run { [stageProgressionUseCase, taskId = state.task.id] send in
                    do {
                        try await stageProgressionUseCase.resetStageRecords(for: taskId)
                    } catch {
                        Logger.certificationFailed(error: error)
                    }
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
        .ifLet(\.$deleteFailureAlert, action: \.deleteFailureAlert)
    }

    private func deleteTaskEffect(taskId: TaskID) -> Effect<Action> {
        .run { [deleteTaskUseCase] send in
            do {
                try await deleteTaskUseCase.execute(taskId)
                await send(.deleteTaskSucceeded)
            } catch {
                Logger.certificationFailed(error: error)
                await send(.deleteTaskFailed)
            }
        }
    }

    private func resetDeleteFlowState(_ state: inout State) {
        state.isDeleteConfirmationPresented = false
        state.isDeleteFlowPresented = false
        state.deleteFlowStep = .firstGuard
        state.deleteConfirmCountdown = DeleteFlowPolicy.confirmDelaySeconds
        state.isDeleteConfirmEnabled = false
    }
}
