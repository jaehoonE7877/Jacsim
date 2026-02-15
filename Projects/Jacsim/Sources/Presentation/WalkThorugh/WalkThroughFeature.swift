import Foundation
import UserNotifications
import ComposableArchitecture

@Reducer
public struct WalkThroughFeature {
    @Dependency(\.requestNotificationPermissionUseCase) var requestNotificationPermissionUseCase

    @ObservableState
    public struct State: Equatable {
        public var currentPage: Int = 0
        public var fromSetting: Bool
        public let totalPages: Int = 4
        public var notificationPermissionStatus: UNAuthorizationStatus? = nil
        
        public init(fromSetting: Bool) {
            self.fromSetting = fromSetting
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case continueButtonTapped
        case skipButtonTapped
        case requestNotificationPermission
        case notificationPermissionResponse(Bool)
        case delegate(Delegate)
        
        public enum Delegate {
            case completeOnboarding
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .continueButtonTapped:
                if state.currentPage < state.totalPages - 1 {
                    state.currentPage += 1
                    return .none
                } else {
                    return .send(.delegate(.completeOnboarding))
                }
            case .skipButtonTapped:
                return .send(.delegate(.completeOnboarding))
            case .requestNotificationPermission:
                if state.notificationPermissionStatus == .denied || state.notificationPermissionStatus == .authorized {
                    if state.currentPage < state.totalPages - 1 {
                        state.currentPage += 1
                        return .none
                    }
                    return .send(.delegate(.completeOnboarding))
                }
                let requestNotificationPermissionUseCase = requestNotificationPermissionUseCase
                return .run { send in
                    do {
                        let granted = try await requestNotificationPermissionUseCase.requestAuthorization()
                        await send(.notificationPermissionResponse(granted))
                    } catch {
                        await send(.notificationPermissionResponse(false))
                    }
                }
            case let .notificationPermissionResponse(granted):
                state.notificationPermissionStatus = granted ? .authorized : .denied
                if granted, state.currentPage < state.totalPages - 1 {
                    state.currentPage += 1
                }
                return .none
            case .binding, .delegate:
                return .none
            }
        }
    }
}
