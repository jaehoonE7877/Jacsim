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

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case continueButtonTapped
        case skipButtonTapped
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case completeOnboarding
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .continueButtonTapped:
                return advanceOrComplete(state: &state)

            case .skipButtonTapped:
                return .send(.delegate(.completeOnboarding))

            case .binding, .delegate:
                return .none
            }
        }
    }

    private func advanceOrComplete(state: inout State) -> Effect<Action> {
        if state.currentPage < state.totalPages - 1 {
            state.currentPage += 1
            return .none
        }
        return .send(.delegate(.completeOnboarding))
    }
}
