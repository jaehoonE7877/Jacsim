import Foundation
import ComposableArchitecture
import Domain
import DesignSystem
import JacsimClient

@Reducer
public struct CalendarFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedDate: Date = Date()
        public var calendarScope: JSCalendarScope = .month
        public var tasks: [Domain.Task] = []
        public var eventDates: [Date] = []
        public var dateColors: [Date: TaskSuccessRate] = [:]
        public var isLoading: Bool = false
        public var loadFailed: Bool = false

        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case dateSelected(Date)
        case tasksResponse([Domain.Task])
        case tasksLoadFailed
    }

    @Dependency(\.taskRepository) var taskRepository
    @Dependency(\.taskReadModelQueries) var taskReadModelQueries

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.loadFailed = false
                return .run { [taskRepository] send in
                    do {
                        let tasks = try await taskRepository.fetchActiveTasks()
                        await send(.tasksResponse(tasks))
                    } catch {
                        await send(.tasksLoadFailed)
                    }
                }

            case let .dateSelected(date):
                state.selectedDate = date
                return .none

            case let .tasksResponse(tasks):
                let summary = taskReadModelQueries.calendar(tasks: tasks)
                state.tasks = tasks
                state.eventDates = summary.eventDates
                state.dateColors = summary.dateColors
                state.isLoading = false
                state.loadFailed = false
                return .none

            case .tasksLoadFailed:
                state.isLoading = false
                state.loadFailed = true
                return .none

            case .binding:
                return .none
            }
        }
    }
}
