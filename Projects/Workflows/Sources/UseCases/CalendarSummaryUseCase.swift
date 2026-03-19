import Foundation
import Domain

public struct CalendarSummaryUseCase: Sendable {
    public struct Input: Sendable, Equatable {
        public let tasks: [Task]

        public init(tasks: [Task]) {
            self.tasks = tasks
        }
    }

    public struct Output: Sendable, Equatable {
        public let eventDates: [Date]
        public let dateColors: [Date: TaskSuccessRate]

        public init(eventDates: [Date], dateColors: [Date: TaskSuccessRate]) {
            self.eventDates = eventDates
            self.dateColors = dateColors
        }
    }

    public var execute: @Sendable (Input) -> Output

    public init(execute: @escaping @Sendable (Input) -> Output) {
        self.execute = execute
    }
}

extension CalendarSummaryUseCase {
    public static func live(
        calendarEventService: CalendarEventService = CalendarEventService()
    ) -> Self {
        Self(
            execute: { input in
                Output(
                    eventDates: calendarEventService.calculateEventDates(from: input.tasks),
                    dateColors: calendarEventService.calculateDateColors(from: input.tasks)
                )
            }
        )
    }
}
