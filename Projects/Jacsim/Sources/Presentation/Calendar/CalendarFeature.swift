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
        
        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case dateSelected(Date)
        case tasksResponse([Domain.Task])
    }

    @Dependency(\.taskRepository) var taskRepository

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
                state.eventDates = calculateEventDates(from: tasks)
                return .none
                
            case .binding:
                return .none
            }
        }
    }
    
    private func calculateEventDates(from tasks: [Domain.Task]) -> [Date] {
        let calendar = Calendar.current
        var dates = Set<Date>()
        
        for task in tasks {
            let start = calendar.startOfDay(for: task.startDate)
            let end = calendar.startOfDay(for: task.endDate)
            
            var currentDate = start
            while currentDate <= end {
                dates.insert(currentDate)
                guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = next
            }
        }
        return Array(dates)
    }
}
