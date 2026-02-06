import Foundation
import Domain
import ComposableArchitecture
import UIKit
import Photos

@Reducer
public struct TaskEditFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: TaskID { task.id }
        public var task: Task
        public var title: String
        public var successTarget: Int
        public var maxSuccessTarget: Int
        public var image: UIImage?
        public var isAlarmEnabled: Bool
        public var alarmDate: Date

        public init(task: Task, maxSuccessTarget: Int) {
            self.task = task
            self.title = task.title
            self.successTarget = task.successCount
            self.maxSuccessTarget = maxSuccessTarget
            self.isAlarmEnabled = task.isNotificationEnabled
            self.alarmDate = task.alarmDate ?? Date()
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case imageLoaded(UIImage?)
        case saveButtonTapped
        case cancelButtonTapped
        case imageSelected(UIImage)
        case delegate(Delegate)

        public enum Delegate {
            case saved(String, Int, UIImage?, Bool, Date)
            case cancelled
        }
    }

    @Dependency(\.imageStore) var imageStore
    @Dependency(\.notificationScheduler) var notificationScheduler

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                let key = state.task.mainImageKey
                return .run { send in
                    let imageData = await imageStore.loadImage(key)
                    let image = imageData.flatMap { UIImage(data: $0) }
                    await send(.imageLoaded(image))
                }

            case let .imageLoaded(image):
                state.image = image
                return .none

            case .saveButtonTapped:
                let title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
                let taskId = state.task.id
                let successTarget = state.successTarget
                let image = state.image
                let isAlarmEnabled = state.isAlarmEnabled
                let alarmDate = state.alarmDate
                return .run { [notificationScheduler, title, taskId, successTarget, image, isAlarmEnabled, alarmDate] send in
                    await notificationScheduler.cancelReminder(taskId)
                    if isAlarmEnabled {
                        let components = Calendar.current.dateComponents([.hour, .minute], from: alarmDate)
                        let hour = components.hour ?? 0
                        let minute = components.minute ?? 0
                        func scheduleDailyReminder(_ taskId: TaskID, _ hour: Int, _ minute: Int) async {
                            let time = DateComponents(hour: hour, minute: minute)
                            try? await notificationScheduler.scheduleDailyReminder(taskId, title, time)
                        }
                        await scheduleDailyReminder(taskId, hour, minute)
                    }
                    await send(.delegate(.saved(title, successTarget, image, isAlarmEnabled, alarmDate)))
                }

            case .cancelButtonTapped:
                return .send(.delegate(.cancelled))

            case let .imageSelected(image):
                state.image = image
                return .none

            case .binding, .delegate:
                return .none
            }
        }
    }
}
