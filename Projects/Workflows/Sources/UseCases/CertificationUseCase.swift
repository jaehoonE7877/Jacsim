import Foundation
import Domain
import Ports

public struct CertificationUseCase: Sendable {
    private let taskRepository: TaskRepositoryPort

    public init(taskRepository: TaskRepositoryPort) {
        self.taskRepository = taskRepository
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

        try await taskRepository.updateTask(task)
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
        try await taskRepository.updateTask(task)
    }
}

public enum CertificationError: Error {
    case taskNotFound
    case invalidRecordIndex
}
