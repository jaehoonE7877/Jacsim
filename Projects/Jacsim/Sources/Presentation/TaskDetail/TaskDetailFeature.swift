import Foundation
import Domain
import ComposableArchitecture
import UIKit
import DSKit

@Reducer
public struct TaskDetailFeature {
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

    @Dependency(\.jacsimClient) var jacsimClient
    @Dependency(\.imageStore) var imageStore
    @Dependency(\.notificationScheduler) var notificationScheduler
    @Dependency(\.challengeStateService) var challengeStateService

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let evaluation = challengeStateService.evaluateChallengeState(
                    for: state.task,
                    today: Date()
                )
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
                return .merge(
                    .send(.loadImages),
                    .run { [jacsimClient, stage = evaluation.currentStage] send in
                        guard let stage else { return }
                        let result = await jacsimClient.evaluateStageResult(stage)
                        await send(.stageResultChecked(result))
                    }
                )
                
            case .loadImages:
                return .run { [task = state.task, dayData = state.dayViewData, imageStore] send in
                    let coverImageData = await imageStore.loadImage(task.mainImageKey)
                    let coverImage = coverImageData.flatMap { UIImage(data: $0) }
                    await send(.coverImageLoaded(coverImage))

                    for data in dayData {
                        guard let key = task.imageKey(for: task.dayArray.firstIndex(where: { $0 == data.date }) ?? 0) else { continue }
                        let imageData = await imageStore.loadImage(key)
                        let image = imageData.flatMap { UIImage(data: $0) }
                        await send(.imageLoaded(data.date, image))
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
                state.editTask = TaskEditFeature.State(
                    task: state.task,
                    maxSuccessTarget: state.task.stages.last?.durationDays ?? 3
                )
                return .none
                
            case .notificationSettingsButtonTapped:
                state.editTask = TaskEditFeature.State(
                    task: state.task,
                    maxSuccessTarget: state.task.stages.last?.durationDays ?? 3
                )
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
                return .run { [jacsimClient, notificationScheduler] send in
                    await notificationScheduler.cancelReminder(taskId)
                    try? await jacsimClient.deleteTask(taskId)
                    await send(.delegate(.taskDeleted))
                }
                
            case .deleteCancelled:
                state.isDeleteConfirmationPresented = false
                return .none
                
            case let .dayTapped(date):
                if let index = state.task.dayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                    return .send(.delegate(.navigateToUpdate(state.task, index)))
                }
                return .none

            case .editButtonTapped:
                state.editTask = TaskEditFeature.State(
                    task: state.task,
                    maxSuccessTarget: state.task.stages.last?.durationDays ?? 3
                )
                return .none

            case let .editTask(.presented(.delegate(.saved(title, successTarget, image, isAlarmEnabled, alarmDate)))):
                let task = state.task
                state.editTask = nil
                return .run { [jacsimClient, imageStore, task] send in
                    await jacsimClient.updateTaskInfo(task, title, successTarget, isAlarmEnabled, alarmDate)
                    if let image {
                        let data = image.jpegData(compressionQuality: 0.4)
                        if let data {
                            _ = try? await imageStore.saveImage(task.mainImageKey, data)
                        }
                    }
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
                let title = state.task.title
                return .run { [jacsimClient, notificationScheduler, title] send in
                    _ = await jacsimClient.createNextStage(taskId)
                    await send(.stagePopupDismissed)
                    await send(.onAppear)
                }

            case .viewSuccessRecordTapped:
                state.isStagePopupPresented = true
                state.stagePopupResult = .success
                return .none

            case .retryStageButtonTapped:
                return .run { [jacsimClient, taskId = state.task.id] send in
                    await jacsimClient.resetStageRecords(taskId)
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
