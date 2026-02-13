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
        public var isLoading: Bool = false
        public var loadFailed: Bool = false
        
        public var isOngoingExpanded: Bool = true
        public var isSuccessExpanded: Bool = true
        public var isFailExpanded: Bool = true
        
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tasksResponse(ongoing: [Domain.Task], success: [Domain.Task], fail: [Domain.Task])
        case tasksLoadFailed
        case toggleOngoing
        case toggleSuccess
        case toggleFail
        case taskTapped(Domain.Task)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case navigateToDetail(Domain.Task)
        }
    }

    @Dependency(\.taskQueryClient) var taskQueryClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.loadFailed = false
                return .run { [taskQueryClient] send in
                    do {
                        let ongoing = try await taskQueryClient.fetchActiveTasks()
                        let success = try await taskQueryClient.fetchIsSuccess()
                        let fail = try await taskQueryClient.fetchIsFail()
                        await send(.tasksResponse(ongoing: ongoing, success: success, fail: fail))
                    } catch {
                        await send(.tasksLoadFailed)
                    }
                }
            case let .tasksResponse(ongoing, success, fail):
                state.ongoingTasks = ongoing
                state.successTasks = success
                state.failTasks = fail
                state.isLoading = false
                state.loadFailed = false
                return .none
            case .tasksLoadFailed:
                state.isLoading = false
                state.loadFailed = true
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
            case let .taskTapped(task):
                return .send(.delegate(.navigateToDetail(task)))
            case .delegate:
                return .none
            }
        }
    }
}
