import Foundation
import ComposableArchitecture
import Domain
import DesignSystem

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

    @Dependency(\.taskQueryUseCase) var taskQueryUseCase
    @Dependency(\.calendarEventServiceUseCase) var calendarEventServiceUseCase

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.loadFailed = false
                return .run { [taskQueryUseCase] send in
                    do {
                        let tasks = try await taskQueryUseCase.fetchActiveTasks()
                        await send(.tasksResponse(tasks))
                    } catch {
                        await send(.tasksLoadFailed)
                    }
                }

            case let .dateSelected(date):
                state.selectedDate = date
                return .none

            case let .tasksResponse(tasks):
                state.tasks = tasks
                state.eventDates = calendarEventServiceUseCase.calculateEventDates(tasks)
                state.dateColors = calendarEventServiceUseCase.calculateDateColors(tasks)
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
