import Foundation
import Domain
import Ports

public struct TaskUpdateUseCase: Sendable {
    private let taskRepository: TaskRepositoryPort

    public init(taskRepository: TaskRepositoryPort) {
        self.taskRepository = taskRepository
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
        updatedTask.alarm = isNotificationEnabled ? alarmDate : nil

        if var lastStage = updatedTask.stages.last {
            lastStage.durationDays = durationDays
            let index = updatedTask.stages.count - 1
            updatedTask.stages[index] = lastStage
        }

        try await taskRepository.updateTask(updatedTask)
        return updatedTask
    }
}
