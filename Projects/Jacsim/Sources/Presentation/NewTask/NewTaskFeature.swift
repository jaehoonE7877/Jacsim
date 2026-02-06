import Foundation
import Domain
import ComposableArchitecture
import SwiftUI
import PhotosUI
import Core

@Reducer
public struct NewTaskFeature {
    @ObservableState
    public struct State: Equatable {
        public var title: String = ""
        public var startDate: Date = Date()
        public var endDate: Date = Date().addingTimeInterval(86400 * 7)
        public var successCount: Int = 1
        public var image: UIImage?
        public var photoPickerItem: PhotosPickerItem?
        public var stageType: StageType = .three
        public var alarmDate: Date = State.defaultAlarmDate()
        public var isAlarmEnabled: Bool = false
        public var isSaving: Bool = false
        public var saveFailed: Bool = false
        
        public var path = StackState<Path.State>()
        @Presents public var alert: AlertState<Action.Alert>?
        
        public init() {
            self.alarmDate = State.defaultAlarmDate()
        }

        private static func defaultAlarmDate() -> Date {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 21
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackAction<Path.State, Path.Action>)
        case saveButtonTapped
        case saveCompleted(Result<Void, Error>)
        case imageSelected(UIImage)
        case photoPickerItemChanged(PhotosPickerItem?)
        case nextButtonTapped
        case confirmAlarmButtonTapped
        case cancelButtonTapped
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)
        
        public enum Alert: Equatable {
            case dismiss
        }
        
        public enum Delegate {
            case taskCreated
        }
    }

    public struct Path: Reducer {
        @ObservableState
        @CasePathable
        @dynamicMemberLookup
        public enum State: Equatable, Hashable {
            case alarmInput
            case summary
        }
        @CasePathable
        @dynamicMemberLookup
        public enum Action: Equatable {
            case alarmInput
            case summary
        }
        public var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }

    @Dependency(\.jacsimClient) var jacsimClient
    @Dependency(\.notificationScheduler) var notificationScheduler
    @Dependency(\.imageStore) var imageStore
    @Dependency(\.userSettingsRepository) var userSettingsRepository

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                state.path.append(.alarmInput)
                return .none
            case .confirmAlarmButtonTapped:
                state.path.append(.summary)
                return .none
            case .saveButtonTapped:
                let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedTitle.isEmpty, let image = state.image else { return .none }
                state.isSaving = true
                state.saveFailed = false
                let stageType = state.stageType
                let startDate = Calendar.current.startOfDay(for: Date())
                let endDate = Calendar.current.date(
                    byAdding: .day,
                    value: stageType.durationDays - 1,
                    to: startDate
                ) ?? startDate
                let isAlarmEnabled = state.isAlarmEnabled
                let alarmDate = state.alarmDate
                
                let createTaskUseCase = CreateTaskUseCase()
                let task: Task = {
                    var task = createTaskUseCase.createTask(
                        title: trimmedTitle,
                        startDate: startDate,
                        endDate: endDate,
                        stageType: stageType
                    )
                    task.isNotificationEnabled = isAlarmEnabled
                    task.alarmDate = isAlarmEnabled ? alarmDate : nil
                    return task
                }()
                
                Logger.taskCreated(title: task.title, taskId: task.id.rawValue.uuidString, startDate: task.startDate, endDate: task.endDate)
                return .run { [jacsimClient, notificationScheduler, imageStore, userSettingsRepository] send in
                    do {
                        if let data = image.jpegData(compressionQuality: 0.4) {
                            _ = try await imageStore.saveImage(task.mainImageKey, data)
                        }
                        try await jacsimClient.addTask(task)
                        if isAlarmEnabled {
                            let isNotificationEnabled = await userSettingsRepository.isNotificationEnabled()
                            if isNotificationEnabled {
                                let time = Calendar.current.dateComponents([.hour, .minute], from: alarmDate)
                                try? await notificationScheduler.scheduleDailyReminder(task.id, task.title, time)
                            }
                        }
                        await send(.saveCompleted(.success(())))
                    } catch {
                        await send(.saveCompleted(.failure(error)))
                    }
                }
            case .saveCompleted(.success):
                state.isSaving = false
                return .send(.delegate(.taskCreated))
            case .saveCompleted(.failure):
                state.isSaving = false
                state.saveFailed = true
                return .none
            case let .imageSelected(image):
                state.image = image
                state.saveFailed = false
                return .none
            case let .photoPickerItemChanged(item):
                guard let item else { return .none }
                return .run { send in
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await send(.imageSelected(image))
                    }
                }
            case .binding(\.title):
                state.saveFailed = false
                return .none
            case .binding, .path, .cancelButtonTapped, .delegate, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}
