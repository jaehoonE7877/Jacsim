import Foundation
import SwiftData
import Domain
import ComposableArchitecture
import UIKit
import Data
import DSKit

public enum ChallengeDetailState: Equatable {
    case stagePending
    case stageSuccess
    case stageFail
    case habitCompleted
    
    public var isStagePending: Bool {
        self == .stagePending
    }
    
    public var isStageSuccess: Bool {
        self == .stageSuccess
    }
    
    public var isStageFail: Bool {
        self == .stageFail
    }
    
    public var isHabitCompleted: Bool {
        self == .habitCompleted
    }
}

public enum TodayStatus: Equatable {
    case notCertified
    case certified
    
    public var title: String {
        switch self {
        case .notCertified:
            return "오늘 미인증"
        case .certified:
            return "오늘 인증 완료"
        }
    }
    
    public var chipState: JSStatusChipState {
        switch self {
        case .notCertified:
            return .pending
        case .certified:
            return .completed
        }
    }
}

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

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return calculateChallengeState(&state)
                
            case .loadImages:
                return .run { [task = state.task, dayData = state.dayViewData, imageStore] send in
                    for data in dayData {
                        guard let key = task.imageKey(for: task.dayArray.firstIndex(where: { $0 == data.date }) ?? 0) else { continue }
                        let imageData = await imageStore.loadImage(key)
                        let image = imageData.flatMap { UIImage(data: $0) }
                        await send(.imageLoaded(data.date, image))
                    }
                }
                
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
                return .send(.delegate(.navigateToPhotoChange(state.task)))
                
            case .notificationSettingsButtonTapped:
                return .send(.delegate(.navigateToNotificationSettings(state.task)))
                
            case .editMemoButtonTapped:
                return .send(.delegate(.navigateToMemoEdit(state.task)))

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
                    let reminderTime = await MainActor.run { () -> DateComponents? in
                        let context = SwiftDataStack.shared.context
                        let descriptor = FetchDescriptor<UserJacsimModel>(
                            predicate: #Predicate { $0.id == taskId.rawValue }
                        )
                        guard let model = (try? context.fetch(descriptor))?.first else { return nil }
                        guard let alarm = model.alarm, model.isNotificationEnabled else { return nil }
                        return Calendar.current.dateComponents([.hour, .minute], from: alarm)
                    }
                    if let reminderTime {
                        try? await notificationScheduler.scheduleDailyReminder(taskId, title, reminderTime)
                    }
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
                return .none

            case .viewHistoryButtonTapped:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$editTask, action: \.editTask) {
            TaskEditFeature()
        }
    }

    private func calculateChallengeState(_ state: inout State) -> Effect<Action> {
        let task = state.task
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let currentStage = task.stages.last
        state.currentStage = currentStage

        state.remainingSuccessCount = max(0, (currentStage?.durationDays ?? 0) - task.records.filter(\.check).count)

        let isTodayInRange = today >= calendar.startOfDay(for: task.startDate)
            && today <= calendar.startOfDay(for: task.endDate)

        if isTodayInRange {
            let todayRecord = task.records.first { calendar.isDate($0.date, inSameDayAs: today) }
            state.todayStatus = (todayRecord?.check == true) ? .certified : .notCertified
            state.todayMemo = todayRecord?.memo ?? ""
        } else {
            state.todayStatus = .notCertified
        }

        if let stage = currentStage {
            let stageResult = stage.result
            let isFinalStage = stage.stageType == .thirty

            switch stageResult {
            case .inProgress:
                state.challengeState = .stagePending
            case .success:
                if isFinalStage {
                    state.challengeState = .habitCompleted
                } else {
                    state.challengeState = .stageSuccess
                }
            case .fail:
                state.challengeState = .stageFail
            }

            let stageStart = stage.startDate
            let stageEnd = stage.endDate
            let totalStageDays = stage.durationDays

            let stageRecords = task.records.filter { record in
                let recordDate = calendar.startOfDay(for: record.date)
                return recordDate >= calendar.startOfDay(for: stageStart)
                    && recordDate <= calendar.startOfDay(for: stageEnd)
            }
            let successCount = stageRecords.filter(\.check).count

            state.stageProgress = totalStageDays > 0 ? Double(successCount) / Double(totalStageDays) : 0
            state.stageProgressText = "\(successCount)/\(totalStageDays)"
        } else {
            state.challengeState = .stagePending
            state.stageProgress = 0
            state.stageProgressText = "0/7"
        }

        let dates = task.dayArray.reversed()
        state.dayViewData = dates.enumerated().map { index, date in
            let originalIndex = task.dayArray.count - 1 - index
            let memo = task.records.indices.contains(originalIndex) ? task.records[originalIndex].memo : "인증해주세요"
            let isChecked = task.records.indices.contains(originalIndex) ? task.records[originalIndex].check : false
            return State.DayViewData(date: date, memo: memo, image: nil, isChecked: isChecked)
        }

        return .merge(
            .send(.loadImages),
            .run { [jacsimClient, stage = currentStage] send in
                guard let stage else { return }
                let result = await jacsimClient.evaluateStageResult(stage)
                await send(.stageResultChecked(result))
            }
        )
    }
}
