import Foundation
import ComposableArchitecture

@Reducer
public struct AllTaskFeature {
    @ObservableState
    public struct State: Equatable {
        public var ongoingTasks: [UserJacsim] = []
        public var successTasks: [UserJacsim] = []
        public var failTasks: [UserJacsim] = []
        
        public var isOngoingExpanded: Bool = true
        public var isSuccessExpanded: Bool = true
        public var isFailExpanded: Bool = true
        
        public init() {}
    }

    public enum Action {
        case onAppear
        case tasksResponse(ongoing: [UserJacsim], success: [UserJacsim], fail: [UserJacsim])
        case toggleOngoing
        case toggleSuccess
        case toggleFail
        case taskTapped(UserJacsim)
    }

    @Dependency(\.jacsimClient) var jacsimClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let ongoing = await jacsimClient.fetchActiveTasks()
                    let success = await jacsimClient.fetchIsSuccess()
                    let fail = await jacsimClient.fetchIsFail()
                    await send(.tasksResponse(ongoing: ongoing, success: success, fail: fail))
                }
            case let .tasksResponse(ongoing, success, fail):
                state.ongoingTasks = ongoing
                state.successTasks = success
                state.failTasks = fail
                return .none
            case .toggleOngoing:
                state.isOngoingExpanded.toggle()
                return .none
            case .toggleSuccess:
                state.isSuccessExpanded.toggle()
                return .none
            case .toggleFail:
                state.isFailExpanded.toggle()
                return .none
            case .taskTapped:
                return .none
            }
        }
    }
}
