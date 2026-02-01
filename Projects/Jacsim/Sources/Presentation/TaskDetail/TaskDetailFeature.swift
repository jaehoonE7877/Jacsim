import Foundation
import SwiftData
import Domain
import ComposableArchitecture
import UIKit
import Data

@Reducer
public struct TaskDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var task: Domain.Task
        public var dayViewData: [DayViewData] = []
        public var remainingSuccessCount: Int = 0
        public var isStagePopupPresented: Bool = false
        public var stagePopupResult: StageResult = .inProgress

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
        case deleteAlarmButtonTapped
        case deleteJacsimButtonTapped
        case dayTapped(Date)
        case editButtonTapped
        case editTask(PresentationAction<TaskEditFeature.Action>)
        case stageResultChecked(StageResult)
        case stagePopupDismissed
        case nextStageButtonTapped
        
        case delegate(Delegate)
        public enum Delegate {
            case taskDeleted
            case navigateToUpdate(Domain.Task, Int)
        }
    }

    @Dependency(\.jacsimClient) var jacsimClient
    @Dependency(\.imageStore) var imageStore
    @Dependency(\.notificationScheduler) var notificationScheduler

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.remainingSuccessCount = max(0, state.task.stages.last?.durationDays ?? 0 - state.task.records.filter(\.check).count)
                let dates = state.task.dayArray
                state.dayViewData = dates.enumerated().map { index, date in
                    let memo = state.task.records.indices.contains(index) ? state.task.records[index].memo : "인증해주세요"
                    let isChecked = state.task.records.indices.contains(index) ? state.task.records[index].check : false
                    return State.DayViewData(date: date, memo: memo, image: nil, isChecked: isChecked)
                }
                let stage = state.task.stages.last
                return .merge(
                    .send(.loadImages),
                    .run { [jacsimClient, stage] send in
                        guard let stage else { return }
                        let result = await jacsimClient.evaluateStageResult(stage)
                        await send(.stageResultChecked(result))
                    }
                )
                
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
                
            case .deleteAlarmButtonTapped:
                let taskId = state.task.id
                return .run { [jacsimClient] send in
                    await jacsimClient.deleteAlarm(taskId)
                    await send(.onAppear)
                }
                
            case .deleteJacsimButtonTapped:
                let taskId = state.task.id
                return .run { [jacsimClient, notificationScheduler] send in
                    await notificationScheduler.cancelReminder(taskId)
                    try? await jacsimClient.deleteTask(taskId)
                    await send(.delegate(.taskDeleted))
                }
                
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

            case let .stageResultChecked(result):
                if result != .inProgress {
                    state.stagePopupResult = result
                    state.isStagePopupPresented = true
                }
                return .none

            case .stagePopupDismissed:
                state.isStagePopupPresented = false
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

            case .editTask, .delegate:
                return .none
            }
        }
        .ifLet(\.$editTask, action: \.editTask) {
            TaskEditFeature()
        }
    }
}
