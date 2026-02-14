import Foundation
import Domain
import ExternalInterface
import Core

public struct CertifyTaskTodayUseCase: Sendable {
    public struct Input: Sendable, Equatable {
        public var task: Task
        public var index: Int
        public var memo: String
        public var imageData: Data?

        public init(
            task: Task,
            index: Int,
            memo: String,
            imageData: Data?
        ) {
            self.task = task
            self.index = index
            self.memo = memo
            self.imageData = imageData
        }
    }

    public var execute: @Sendable (Input) async throws -> Void

    public init(execute: @escaping @Sendable (Input) async throws -> Void) {
        self.execute = execute
    }
}

extension CertifyTaskTodayUseCase {
    static func live(
        taskRepository: TaskRepositoryPort,
        imageStore: ImageStorePort
    ) -> Self {
        let certificationUseCase = CertificationUseCase(taskRepository: taskRepository)
        return Self(
            execute: { input in
                Logger.certificationStarted(
                    taskId: input.task.id.rawValue.uuidString,
                    memo: input.memo,
                    hasImage: input.imageData != nil
                )
                let certifyStartTime = Date()

                let imagePath: String?
                if let data = input.imageData,
                   let key = input.task.imageKey(for: input.index) {
                    do {
                        _ = try await imageStore.saveImage(key, data)
                        Logger.imageSaved(key: key)
                        imagePath = key
                    } catch {
                        Logger.certificationFailed(error: error)
                        throw error
                    }
                } else {
                    imagePath = nil
                }

                do {
                    try await certificationUseCase.certifyToday(
                        taskId: input.task.id,
                        index: input.index,
                        memo: input.memo,
                        imagePath: imagePath
                    )
                    Logger.certificationCompleted(
                        duration: Date().timeIntervalSince(certifyStartTime),
                        index: input.index,
                        check: true,
                        memo: input.memo,
                        imagePath: imagePath
                    )
                } catch {
                    Logger.certificationFailed(error: error)
                }
            }
        )
    }
}
