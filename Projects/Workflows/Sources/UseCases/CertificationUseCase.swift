import Foundation
import Domain
import Ports

public struct CertificationUseCase: Sendable {
    private let taskRepository: TaskRepositoryPort
    private let taskLifecycleService: TaskLifecycleService

    public init(
        taskRepository: TaskRepositoryPort,
        taskLifecycleService: TaskLifecycleService = TaskLifecycleService()
    ) {
        self.taskRepository = taskRepository
        self.taskLifecycleService = taskLifecycleService
    }

    public func certifyToday(
        taskId: TaskID,
        index: Int,
        memo: String,
        imagePath: String?
    ) async throws {
        guard var task = try await taskRepository.fetchTask(taskId) else {
            throw CertificationError.taskNotFound
        }
        guard task.records.indices.contains(index) else {
            throw CertificationError.invalidRecordIndex
        }

        task.records[index].check = true
        task.records[index].memo = memo
        task.records[index].imagePath = imagePath

        let normalizedTask = taskLifecycleService.normalize(task)
        try await taskRepository.updateTask(normalizedTask)
    }

    public func updateMemo(
        taskId: TaskID,
        index: Int,
        memo: String
    ) async throws {
        guard var task = try await taskRepository.fetchTask(taskId) else {
            throw CertificationError.taskNotFound
        }
        guard task.records.indices.contains(index) else {
            throw CertificationError.invalidRecordIndex
        }

        task.records[index].memo = memo
        let normalizedTask = taskLifecycleService.normalize(task)
        try await taskRepository.updateTask(normalizedTask)
    }
}

public enum CertificationError: Error {
    case taskNotFound
    case invalidRecordIndex
}
