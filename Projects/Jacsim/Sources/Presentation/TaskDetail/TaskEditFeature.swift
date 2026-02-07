import Foundation
import Domain
import ComposableArchitecture
import SwiftUI
import UIKit
import PhotosUI

@Reducer
public struct TaskEditFeature {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: TaskID { task.id }
        public var task: Task
        public var title: String
        public var lastAcceptedTitle: String
        public var image: UIImage?
        public var photoPickerItem: PhotosPickerItem?
        public var isAlarmEnabled: Bool
        public var alarmDate: Date
        public var toastMessage: String? = nil

        public init(task: Task) {
            self.task = task
            self.title = task.title
            self.lastAcceptedTitle = task.title
            self.isAlarmEnabled = task.isNotificationEnabled
            self.alarmDate = task.alarm ?? Date()
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case imageLoaded(UIImage?)
        case saveButtonTapped
        case cancelButtonTapped
        case imageSelected(UIImage)
        case photoPickerItemChanged(PhotosPickerItem?)
        case toastDismissed
        case delegate(Delegate)

        public enum Delegate {
            case saved(String, UIImage?, Bool, Date)
            case cancelled
        }
    }

    @Dependency(\.imageStore) var imageStore
    @Dependency(\.notificationScheduler) var notificationScheduler
    @Dependency(\.userSettingsRepository) var userSettingsRepository

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
                let image = state.image
                let isAlarmEnabled = state.isAlarmEnabled
                let alarmDate = state.alarmDate
                return .run { [notificationScheduler, userSettingsRepository, title, taskId, image, isAlarmEnabled, alarmDate] send in
                    let reminderUseCase = ReminderSchedulingUseCase()
                    let isGlobalNotificationEnabled = await userSettingsRepository.isNotificationEnabled()
                    await reminderUseCase.scheduleReminderIfNeeded(
                        taskID: taskId,
                        title: title,
                        isAlarmEnabled: isAlarmEnabled,
                        alarmDate: alarmDate,
                        isGlobalNotificationEnabled: isGlobalNotificationEnabled,
                        cancelExistingReminder: true,
                        notificationScheduler: notificationScheduler
                    )
                    await send(.delegate(.saved(title, image, isAlarmEnabled, alarmDate)))
                }

            case .cancelButtonTapped:
                return .send(.delegate(.cancelled))

            case let .imageSelected(image):
                state.image = image
                return .none

            case let .photoPickerItemChanged(item):
                guard let item else { return .none }
                return .run { send in
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await send(.imageSelected(image))
                    }
                }

            case .toastDismissed:
                state.toastMessage = nil
                return .none

            case .binding(\.title):
                let result = TextInputLimiter.enforce(
                    previousAcceptedText: state.lastAcceptedTitle,
                    candidateText: state.title,
                    policy: .title
                )
                switch result {
                case let .accepted(text):
                    state.title = text
                    state.lastAcceptedTitle = text
                case let .rejected(keep):
                    state.title = keep
                    state.toastMessage = TextInputFieldPolicy.title.exceededToastMessage
                }
                return .none

            case .binding, .delegate:
                return .none
            }
        }
    }
}
