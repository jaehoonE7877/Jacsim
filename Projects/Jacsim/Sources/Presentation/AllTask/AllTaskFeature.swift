import Foundation
import Domain
import ComposableArchitecture
import JacsimClient

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
        case createTaskButtonTapped
        case taskTapped(Domain.Task)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case navigateToDetail(Domain.Task)
            case createTaskRequested
        }
    }

    @Dependency(\.taskRepository) var taskRepository
    @Dependency(\.allTaskSummaryUseCase) var allTaskSummaryUseCase

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.loadFailed = false
                return .run { [taskRepository, allTaskSummaryUseCase] send in
                    do {
                        let ongoing = try await taskRepository.fetchActiveTasks()
                        let done = try await taskRepository.fetchTasksByStatus(.done)
                        let summary = allTaskSummaryUseCase.execute(
                            .init(ongoingTasks: ongoing, doneTasks: done)
                        )
                        await send(
                            .tasksResponse(
                                ongoing: summary.ongoingTasks,
                                success: summary.successTasks,
                                fail: summary.failTasks
                            )
                        )
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
            case .createTaskButtonTapped:
                return .send(.delegate(.createTaskRequested))
            case let .taskTapped(task):
                return .send(.delegate(.navigateToDetail(task)))
            case .delegate:
                return .none
            }
        }
    }
}
