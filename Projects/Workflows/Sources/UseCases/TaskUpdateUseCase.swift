import Foundation
import Domain
import Ports

public struct TaskUpdateUseCase: Sendable {
    private let taskRepository: TaskRepositoryPort
    private let taskLifecycleService: TaskLifecycleService

    public init(
        taskRepository: TaskRepositoryPort,
        taskLifecycleService: TaskLifecycleService = TaskLifecycleService()
    ) {
        self.taskRepository = taskRepository
        self.taskLifecycleService = taskLifecycleService
    }

    func preparedTask(
        task: Task,
        title: String,
        durationDays: Int,
        isNotificationEnabled: Bool,
        alarmDate: Date,
        now: Date = .now
    ) -> Task {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.isNotificationEnabled = isNotificationEnabled
        updatedTask.alarm = isNotificationEnabled ? alarmDate : nil

        if var lastStage = updatedTask.stages.last {
            lastStage.durationDays = durationDays
            let index = updatedTask.stages.count - 1
            updatedTask.stages[index] = lastStage
        }

        return taskLifecycleService.normalize(updatedTask, now: now)
    }

    public func updateTaskInfo(
        task: Task,
        title: String,
        durationDays: Int,
        isNotificationEnabled: Bool,
        alarmDate: Date
    ) async throws -> Task {
        let updatedTask = preparedTask(
            task: task,
            title: title,
            durationDays: durationDays,
            isNotificationEnabled: isNotificationEnabled,
            alarmDate: alarmDate
        )
        try await taskRepository.updateTask(updatedTask)
        return updatedTask
    }
}
