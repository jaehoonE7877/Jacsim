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
    
    public enum TaskSuccessRate: Equatable {
        case none
        case low
        case medium
        case high
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
                state.dateColors = calculateDateColors(from: tasks)
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

    private func calculateDateColors(from tasks: [Domain.Task]) -> [Date: TaskSuccessRate] {
        let calendar = Calendar.current
        var dateColors: [Date: TaskSuccessRate] = [:]

        for task in tasks {
            let totalDays = task.dayArray.count
            let completedDays = task.records.filter { $0.check }.count
            let successRate = totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0.0

            let rate: TaskSuccessRate
            if successRate < 0.3 {
                rate = .low
            } else if successRate <= 0.7 {
                rate = .medium
            } else {
                rate = .high
            }

            let start = calendar.startOfDay(for: task.startDate)
            let end = calendar.startOfDay(for: task.endDate)

            var currentDate = start
            while currentDate <= end {
                dateColors[currentDate] = rate
                guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = next
            }
        }

        return dateColors
    }
}
