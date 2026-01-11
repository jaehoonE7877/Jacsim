import Foundation
import ComposableArchitecture
import UIKit

@Reducer
public struct TaskDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var task: UserJacsim
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
        
        public init(task: UserJacsim) {
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
            case navigateToUpdate(UserJacsim, Int)
        }
    }

    @Dependency(\.jacsimClient) var jacsimClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.remainingSuccessCount = max(state.task.success - state.task.memoList.filter(\.check).count, 0)
                let dates = state.task.jacsimDayArray
                state.dayViewData = dates.enumerated().map { index, date in
                    let memo = state.task.memoList.indices.contains(index) ? state.task.memoList[index].memo : "인증해주세요"
                    let isChecked = state.task.memoList.indices.contains(index) ? state.task.memoList[index].check : false
                    return State.DayViewData(date: date, memo: memo, image: nil, isChecked: isChecked)
                }
                let stage = state.task.stages.last
                return .merge(
                    .send(.loadImages),
                    .run { send in
                        guard let stage else { return }
                        let result = await jacsimClient.evaluateStageResult(stage)
                        await send(.stageResultChecked(result))
                    }
                )
                
            case .loadImages:
                return .run { [task = state.task, dayData = state.dayViewData] send in
                    for data in dayData {
                        let dateText = DateFormatType.toString(data.date, to: .fullWithoutYear)
                        let fileName = "\(task.id)_\(dateText).jpg"
                        let image = await DocumentManager.shared.loadImage(fileName: fileName)
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
                let task = state.task
                return .run { send in
                    await jacsimClient.deleteAlarm(task)
                    await send(.onAppear)
                }
                
            case .deleteJacsimButtonTapped:
                let task = state.task
                return .run { send in
                    await jacsimClient.deleteJacsim(task)
                    await send(.delegate(.taskDeleted))
                }
                
            case let .dayTapped(date):
                if let index = state.task.jacsimDayArray.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                    return .send(.delegate(.navigateToUpdate(state.task, index)))
                }
                return .none

            case .editButtonTapped:
                state.editTask = TaskEditFeature.State(
                    task: state.task,
                    maxSuccessTarget: state.task.currentStageType.durationDays
                )
                return .none

            case let .editTask(.presented(.delegate(.saved(title, successTarget, image, isAlarmEnabled, alarmDate)))):
                let task = state.task
                state.editTask = nil
                return .run { send in
                    await jacsimClient.updateTaskInfo(task, title, successTarget, isAlarmEnabled, alarmDate)
                    if let image {
                        DocumentManager.shared.saveImageToDocument(fileName: task.mainImageURL, image: image)
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
                let task = state.task
                return .run { send in
                    _ = await jacsimClient.createNextStage(task)
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
