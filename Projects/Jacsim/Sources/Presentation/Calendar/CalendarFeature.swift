import Foundation
import ComposableArchitecture
import Domain
import DSKit

@Reducer
public struct CalendarFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedDate: Date = Date()
        public var calendarScope: JSCalendarScope = .month
        public var tasks: [Domain.Task] = []
        public var eventDates: [Date] = []
        public var dateColors: [Date: TaskSuccessRate] = [:]

        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case dateSelected(Date)
        case tasksResponse([Domain.Task])
    }

    @Dependency(\.taskRepository) var taskRepository
    @Dependency(\.calendarEventService) var calendarEventService

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let tasks = try await taskRepository.fetchActiveTasks()
                    await send(.tasksResponse(tasks))
                }

            case let .dateSelected(date):
                state.selectedDate = date
                return .none

            case let .tasksResponse(tasks):
                state.tasks = tasks
                state.eventDates = calendarEventService.calculateEventDates(from: tasks)
                state.dateColors = calendarEventService.calculateDateColors(from: tasks)
                return .none

            case .binding:
                return .none
            }
        }
    }
}
