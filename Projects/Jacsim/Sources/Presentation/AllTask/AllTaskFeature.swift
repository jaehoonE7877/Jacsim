import Foundation
import Domain
import ComposableArchitecture

@Reducer
public struct AllTaskFeature {
    @ObservableState
    public struct State: Equatable {
        public var ongoingTasks: [Domain.Task] = []
        public var successTasks: [Domain.Task] = []
        public var failTasks: [Domain.Task] = []
        
        public var isOngoingExpanded: Bool = true
        public var isSuccessExpanded: Bool = true
        public var isFailExpanded: Bool = true
        
        public init() {}
    }

    public enum Action {
        case onAppear
        case tasksResponse(ongoing: [Domain.Task], success: [Domain.Task], fail: [Domain.Task])
        case toggleOngoing
        case toggleSuccess
        case toggleFail
        case taskTapped(Domain.Task)
    }

    @Dependency(\.jacsimClient) var jacsimClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [jacsimClient] send in
                    let ongoing = try await jacsimClient.fetchActiveTasks()
                    let success = try await jacsimClient.fetchIsSuccess()
                    let fail = try await jacsimClient.fetchIsFail()
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
