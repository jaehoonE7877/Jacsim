import Foundation

public struct ActiveTaskService: Sendable {
    public init() {}
    
    public func filterActiveTasks(_ tasks: [Task], referenceDate: Date) -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)
        
        let activeTasks = tasks.filter { task in
            let end = calendar.startOfDay(for: task.endDate)
            return today <= end
        }
        
        return Array(activeTasks.reversed())
    }
}
