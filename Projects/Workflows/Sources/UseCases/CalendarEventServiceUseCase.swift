import Foundation
import Domain

public struct CalendarEventServiceUseCase: Sendable {
    public var calculateEventDates: @Sendable ([Task]) -> [Date]
    public var calculateDateColors: @Sendable ([Task]) -> [Date: TaskSuccessRate]

    public init(
        calculateEventDates: @escaping @Sendable ([Task]) -> [Date],
        calculateDateColors: @escaping @Sendable ([Task]) -> [Date: TaskSuccessRate]
    ) {
        self.calculateEventDates = calculateEventDates
        self.calculateDateColors = calculateDateColors
    }
}

extension CalendarEventServiceUseCase {
    public static func live(
        calendarEventService: CalendarEventService = CalendarEventService()
    ) -> Self {
        Self(
            calculateEventDates: { tasks in
                calendarEventService.calculateEventDates(from: tasks)
            },
            calculateDateColors: { tasks in
                calendarEventService.calculateDateColors(from: tasks)
            }
        )
    }
}
