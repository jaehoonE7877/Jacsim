import Foundation
import ComposableArchitecture

@Reducer
public struct WalkThroughFeature {
    @ObservableState
    public struct State: Equatable {
        public var currentPage: Int = 0
        public var fromSetting: Bool
        public let totalPages: Int = 4
        
        public init(fromSetting: Bool) {
            self.fromSetting = fromSetting
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case continueButtonTapped
        case skipButtonTapped
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
            case .binding, .delegate:
                return .none
            }
        }
    }
}
