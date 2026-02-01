import ComposableArchitecture

@Reducer
public struct ChallengeCreateFeature {
    @ObservableState
    public struct State: Equatable {
        public var newTask: NewTaskFeature.State

        public init() {
            self.newTask = NewTaskFeature.State()
        }
    }

    public enum Action {
        case newTask(NewTaskFeature.Action)
        case cancelButtonTapped
        case delegate(Delegate)

        public enum Delegate {
            case challengeCreated
            case cancelled
        }
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.newTask, action: \.newTask) {
            NewTaskFeature()
        }
        Reduce { state, action in
            switch action {
            case .newTask(.delegate(.taskCreated)):
                return .send(.delegate(.challengeCreated))

            case .cancelButtonTapped, .newTask(.cancelButtonTapped):
                return .send(.delegate(.cancelled))

            case .newTask, .delegate:
                return .none
            }
        }
    }
}
