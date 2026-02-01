import Foundation

public enum TaskSuccessRate: Sendable, Equatable {
    case none
    case low
    case medium
    case high
}

public struct CalendarEventService: Sendable {
    public init() {}
    
    public func calculateEventDates(from tasks: [Task]) -> [Date] {
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
    
    public func calculateDateColors(from tasks: [Task]) -> [Date: TaskSuccessRate] {
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
