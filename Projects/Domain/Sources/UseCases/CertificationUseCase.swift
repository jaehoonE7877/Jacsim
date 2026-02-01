import Foundation

public protocol CertificationUseCaseProtocol: Sendable {
    func certifyToday(
        taskId: TaskID,
        index: Int,
        memo: String,
        imagePath: String?
    ) async throws

    func updateMemo(
        taskId: TaskID,
        index: Int,
        memo: String
    ) async throws
}

public struct CertificationUseCase: CertificationUseCaseProtocol {
    public typealias FetchTaskHandler = @Sendable (TaskID) async throws -> Task?
    public typealias UpdateTaskHandler = @Sendable (Task) async throws -> Void

    private let fetchTask: FetchTaskHandler
    private let updateTask: UpdateTaskHandler

    public init(
        fetchTask: @escaping FetchTaskHandler,
        updateTask: @escaping UpdateTaskHandler
    ) {
        self.fetchTask = fetchTask
        self.updateTask = updateTask
    }

    public func certifyToday(
        taskId: TaskID,
        index: Int,
        memo: String,
        imagePath: String?
    ) async throws {
        guard var task = try await fetchTask(taskId) else {
            throw CertificationError.taskNotFound
        }
        guard task.records.indices.contains(index) else {
            throw CertificationError.invalidRecordIndex
        }

        task.records[index].check = true
        task.records[index].memo = memo
        task.records[index].imagePath = imagePath

        try await updateTask(task)
    }

    public func updateMemo(
        taskId: TaskID,
        index: Int,
        memo: String
    ) async throws {
        guard var task = try await fetchTask(taskId) else {
            throw CertificationError.taskNotFound
        }
        guard task.records.indices.contains(index) else {
            throw CertificationError.invalidRecordIndex
        }

        task.records[index].memo = memo
        try await updateTask(task)
    }
}

public enum CertificationError: Error {
    case taskNotFound
    case invalidRecordIndex
}
