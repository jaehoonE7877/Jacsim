import Foundation

public struct TaskStatusService: Sendable {
    public init() {}
    
    public func filterSuccessTasks(_ tasks: [Task]) -> [Task] {
        tasks.filter { $0.stages.last?.result == .success }
    }
    
    public func filterFailTasks(_ tasks: [Task]) -> [Task] {
        tasks.filter { $0.stages.last?.result == .fail }
    }
}
