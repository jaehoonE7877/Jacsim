import Foundation
import Domain
import ComposableArchitecture
import SwiftUI
import PhotosUI
import JacsimClient
import Shared

@Reducer
public struct NewTaskFeature {
    public enum CreateChallengeStep: Int, CaseIterable, Equatable {
        case basicInfo
        case photo
        case alarmConfirm

        var title: String {
            switch self {
            case .basicInfo:
                return "기본 정보"
            case .photo:
                return "대표 사진"
            case .alarmConfirm:
                return "알림 및 확인"
            }
        }

        var description: String {
            switch self {
            case .basicInfo:
                return "제목과 기간을 먼저 정해요"
            case .photo:
                return "대표 사진은 필수예요"
            case .alarmConfirm:
                return "알림을 선택하고 시작해요"
            }
        }

        var next: CreateChallengeStep? {
            switch self {
            case .basicInfo:
                return .photo
            case .photo:
                return .alarmConfirm
            case .alarmConfirm:
                return nil
            }
        }

        var previous: CreateChallengeStep? {
            switch self {
            case .basicInfo:
                return nil
            case .photo:
                return .basicInfo
            case .alarmConfirm:
                return .photo
            }
        }
    }

    public enum StepValidationError: Equatable {
        case emptyTitle
        case missingPhoto

        var message: String {
            switch self {
            case .emptyTitle:
                return "작심 제목을 입력해 주세요"
            case .missingPhoto:
                return "대표 사진을 선택해 주세요"
            }
        }
    }

    @ObservableState
    public struct State: Equatable {
        public var title: String = ""
        public var lastAcceptedTitle: String = ""
        public var image: UIImage?
        public var photoPickerItem: PhotosPickerItem?
        public var stageType: StageType = .three
        public var alarmDate: Date = State.defaultAlarmDate()
        public var isAlarmEnabled: Bool = false
        public var isSaving: Bool = false
        public var saveFailed: Bool = false
        public var toastMessage: String? = nil
        public var currentStep: CreateChallengeStep = .basicInfo
        public var stepValidationError: StepValidationError?
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

        public var trimmedTitle: String {
            title.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        public var canProceedCurrentStep: Bool {
            switch currentStep {
            case .basicInfo:
                return !trimmedTitle.isEmpty
            case .photo:
                return image != nil
            case .alarmConfirm:
                return true
            }
        }

        public var canSubmit: Bool {
            !trimmedTitle.isEmpty && image != nil
        }

        public var hasUnsavedChanges: Bool {
            !trimmedTitle.isEmpty
                || image != nil
                || stageType != .three
                || isAlarmEnabled
                || currentStep != .basicInfo
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case nextStepTapped
        case previousStepTapped
        case saveButtonTapped
        case saveCompleted(Result<Void, Error>)
        case imageSelected(UIImage)
        case photoPickerItemChanged(PhotosPickerItem?)
        case toastDismissed
        case cancelButtonTapped
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)
        
        public enum Alert: Equatable {
            case discardChangesConfirmed
        }
        
        public enum Delegate: Equatable {
            case taskCreated
            case cancelled
        }
    }

    @Dependency(\.createNewTaskUseCase) var createNewTaskUseCase

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .nextStepTapped:
                guard let next = state.currentStep.next else { return .none }
                guard let validationError = validationError(for: state.currentStep, state: state) else {
                    state.stepValidationError = nil
                    state.currentStep = next
                    return .none
                }
                state.stepValidationError = validationError
                return .none

            case .previousStepTapped:
                guard let previous = state.currentStep.previous else { return .none }
                state.currentStep = previous
                state.stepValidationError = nil
                return .none

            case .saveButtonTapped:
                guard state.currentStep == .alarmConfirm else { return .none }
                let trimmedTitle = state.trimmedTitle

                if trimmedTitle.isEmpty {
                    state.currentStep = .basicInfo
                    state.stepValidationError = .emptyTitle
                    return .none
                }
                guard let image = state.image else {
                    state.currentStep = .photo
                    state.stepValidationError = .missingPhoto
                    return .none
                }

                state.isSaving = true
                state.saveFailed = false
                state.stepValidationError = nil
                let stageType = state.stageType
                let isAlarmEnabled = state.isAlarmEnabled
                let alarmDate = state.alarmDate

                let mainImageData = image.jpegData(compressionQuality: 0.4)
                let input = CreateNewTaskUseCase.Input(
                    title: trimmedTitle,
                    stageType: stageType,
                    isAlarmEnabled: isAlarmEnabled,
                    alarmDate: alarmDate,
                    mainImageData: mainImageData
                )

                return .run { [createNewTaskUseCase] send in
                    do {
                        let task = try await createNewTaskUseCase.execute(input)
                        Logger.taskCreated(
                            title: task.title,
                            taskId: task.id.rawValue.uuidString,
                            startDate: task.startDate,
                            endDate: task.endDate
                        )
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

            case .toastDismissed:
                state.toastMessage = nil
                return .none
            case let .imageSelected(image):
                state.image = image
                state.saveFailed = false
                if state.currentStep == .photo {
                    state.stepValidationError = nil
                }
                return .none

            case let .photoPickerItemChanged(item):
                return .run { send in
                    if let image = await PhotoPickerImageLoader.loadImage(from: item) {
                        await send(.imageSelected(image))
                    }
                }
            case .binding(\.title):
                state.saveFailed = false
                let result = TextInputLimiter.enforce(
                    previousAcceptedText: state.lastAcceptedTitle,
                    candidateText: state.title,
                    policy: .title
                )
                switch result {
                case let .accepted(text):
                    state.title = text
                    state.lastAcceptedTitle = text
                    if state.currentStep == .basicInfo, !state.trimmedTitle.isEmpty {
                        state.stepValidationError = nil
                    }
                case let .rejected(keep):
                    state.title = keep
                    state.toastMessage = TextInputFieldPolicy.title.exceededToastMessage
                }
                return .none

            case .cancelButtonTapped:
                guard !state.isSaving else { return .none }
                guard state.hasUnsavedChanges else {
                    return .send(.delegate(.cancelled))
                }
                state.alert = AlertState {
                    TextState("작성 중인 내용을 버릴까요?")
                } actions: {
                    ButtonState(role: .destructive, action: .discardChangesConfirmed) {
                        TextState("버리기")
                    }
                    ButtonState(role: .cancel) {
                        TextState("계속 작성")
                    }
                } message: {
                    TextState("저장하지 않은 제목, 사진, 알림 설정이 사라집니다.")
                }
                return .none

            case .alert(.presented(.discardChangesConfirmed)):
                state.alert = nil
                return .send(.delegate(.cancelled))

            case .alert:
                return .none

            case .binding, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func validationError(for step: CreateChallengeStep, state: State) -> StepValidationError? {
        switch step {
        case .basicInfo:
            return state.trimmedTitle.isEmpty ? .emptyTitle : nil
        case .photo:
            return state.image == nil ? .missingPhoto : nil
        case .alarmConfirm:
            return nil
        }
    }
}
