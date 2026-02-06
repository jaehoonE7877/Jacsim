import Foundation

public protocol TaskUpdateUseCaseProtocol: Sendable {
    func updateTaskInfo(
        task: Task,
        title: String,
        durationDays: Int,
        isNotificationEnabled: Bool,
        alarmDate: Date
    ) async throws -> Task
}

public struct TaskUpdateUseCase: TaskUpdateUseCaseProtocol {
    public typealias UpdateTaskHandler = @Sendable (Task) async throws -> Void
    
    private let updateTask: UpdateTaskHandler
    
    public init(updateTask: @escaping UpdateTaskHandler) {
        self.updateTask = updateTask
    }
    
    public func updateTaskInfo(
        task: Task,
        title: String,
        durationDays: Int,
        isNotificationEnabled: Bool,
        alarmDate: Date
    ) async throws -> Task {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.isNotificationEnabled = isNotificationEnabled
        updatedTask.alarmDate = isNotificationEnabled ? alarmDate : nil
        
        if var lastStage = updatedTask.stages.last {
            lastStage.durationDays = durationDays
            let index = updatedTask.stages.count - 1
            updatedTask.stages[index] = lastStage
        }
        
        try await updateTask(updatedTask)
        return updatedTask
    }
}
