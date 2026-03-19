import Foundation
import Domain
import ComposableArchitecture
import SwiftUI
import UIKit
import PhotosUI
import JacsimClient

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
        public var isSaving: Bool = false
        public var saveFailed: Bool = false
        public var toastMessage: String? = nil
        @Presents public var alert: AlertState<Action.Alert>?

        public init(task: Task) {
            self.task = task
            self.title = task.title
            self.lastAcceptedTitle = task.title
            self.isAlarmEnabled = task.isNotificationEnabled
            self.alarmDate = task.alarm ?? Date()
        }

        public var trimmedTitle: String {
            title.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        public var hasUnsavedChanges: Bool {
            trimmedTitle != task.title.trimmingCharacters(in: .whitespacesAndNewlines)
                || isAlarmEnabled != task.isNotificationEnabled
                || normalizedTime(alarmDate) != normalizedTime(task.alarm ?? alarmDate)
                || photoPickerItem != nil
        }

        private func normalizedTime(_ date: Date) -> DateComponents {
            Calendar.current.dateComponents([.hour, .minute], from: date)
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case imageLoaded(UIImage?)
        case saveButtonTapped
        case saveCompleted(Result<Void, Error>)
        case cancelButtonTapped
        case imageSelected(UIImage)
        case photoPickerItemChanged(PhotosPickerItem?)
        case toastDismissed
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        public enum Alert: Equatable {
            case discardChangesConfirmed
        }

        public enum Delegate {
            case saved(String, UIImage?, Bool, Date)
            case cancelled
        }
    }

    @Dependency(\.loadImageUseCase) var loadImageUseCase
    @Dependency(\.updateTaskSettingsUseCase) var updateTaskSettingsUseCase

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                let key = state.task.mainImageKey
                let loadImageUseCase = loadImageUseCase
                return .run { send in
                    let imageData = await loadImageUseCase.loadImage(key)
                    let image = imageData.flatMap { UIImage(data: $0) }
                    await send(.imageLoaded(image))
                }

            case let .imageLoaded(image):
                state.image = image
                return .none

            case .saveButtonTapped:
                let title = state.trimmedTitle
                guard !title.isEmpty else {
                    return .none
                }

                state.isSaving = true
                state.saveFailed = false

                let task = state.task
                let image = state.image
                let isAlarmEnabled = state.isAlarmEnabled
                let alarmDate = state.alarmDate
                let durationDays = task.currentStage?.durationDays ?? task.stages.last?.durationDays ?? 3
                let input = UpdateTaskSettingsUseCase.Input(
                    task: task,
                    title: title,
                    durationDays: durationDays,
                    isAlarmEnabled: isAlarmEnabled,
                    alarmDate: alarmDate,
                    mainImageData: image?.jpegData(compressionQuality: 0.4)
                )
                return .run { [updateTaskSettingsUseCase] send in
                    do {
                        try await updateTaskSettingsUseCase.execute(input)
                        await send(.saveCompleted(.success(())))
                    } catch {
                        await send(.saveCompleted(.failure(error)))
                    }
                }

            case .saveCompleted(.success):
                state.isSaving = false
                return .send(.delegate(.saved(state.trimmedTitle, state.image, state.isAlarmEnabled, state.alarmDate)))

            case .saveCompleted(.failure):
                state.isSaving = false
                state.saveFailed = true
                return .none

            case .cancelButtonTapped:
                guard !state.isSaving else { return .none }
                guard state.hasUnsavedChanges else {
                    return .send(.delegate(.cancelled))
                }
                state.alert = AlertState {
                    TextState("변경 사항을 버릴까요?")
                } actions: {
                    ButtonState(role: .destructive, action: .discardChangesConfirmed) {
                        TextState("버리기")
                    }
                    ButtonState(role: .cancel) {
                        TextState("계속 수정")
                    }
                } message: {
                    TextState("저장하지 않은 제목, 사진, 알림 설정이 사라집니다.")
                }
                return .none

            case let .imageSelected(image):
                state.image = image
                state.saveFailed = false
                return .none

            case let .photoPickerItemChanged(item):
                return .run { send in
                    if let image = await PhotoPickerImageLoader.loadImage(from: item) {
                        await send(.imageSelected(image))
                    }
                }

            case .toastDismissed:
                state.toastMessage = nil
                return .none

            case .alert(.presented(.discardChangesConfirmed)):
                state.alert = nil
                return .send(.delegate(.cancelled))

            case .alert:
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

            case .binding:
                state.saveFailed = false
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
