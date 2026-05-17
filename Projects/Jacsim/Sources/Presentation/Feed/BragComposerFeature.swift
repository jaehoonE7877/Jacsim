import Domain
import Foundation
import Observation
import UIKit

public struct BragComposerPrefill: Sendable {
    public let taskId: TaskID?
    public let taskTitle: String?
    public let type: Domain.BragType
    public let body: String

    public init(
        taskId: TaskID?,
        taskTitle: String?,
        type: Domain.BragType,
        body: String
    ) {
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.type = type
        self.body = body
    }
}

@MainActor
@Observable
public final class BragComposerModel {
    public var body: String = ""
    public var tasks: [Domain.Task] = []
    public var selectedTaskID: TaskID?
    public var selectedVisibility: TaskVisibility = .private
    public var selectedImage: UIImage?
    public var imagePaths: [String] = []
    public var toastMessage: String?
    public var isSaving: Bool = false

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private let onCompleted: () -> Void
    @ObservationIgnored private let prefill: BragComposerPrefill?
    @ObservationIgnored private var loadTask: _Concurrency.Task<Void, Never>?

    private let currentUserID = SocialLocalSession.currentUserID

    public init(
        dependencies: JacsimDependencies,
        prefill: BragComposerPrefill? = nil,
        onCompleted: @escaping () -> Void = {}
    ) {
        self.dependencies = dependencies
        self.prefill = prefill
        self.onCompleted = onCompleted
        if let prefill {
            self.body = prefill.body
            self.selectedTaskID = prefill.taskId
        }
    }

    deinit {
        loadTask?.cancel()
    }

    public var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var canSubmit: Bool {
        !trimmedBody.isEmpty && !isSaving
    }

    public var selectedTask: Domain.Task? {
        tasks.first { $0.id == selectedTaskID }
    }

    public var suggestedType: Domain.BragType {
        if let prefill {
            return prefill.type
        }
        guard let selectedTask else { return .completion }
        if selectedTask.stages.last?.result == .success {
            return .graduation
        }
        if selectedTask.completedDays >= 7 {
            return .streak
        }
        return .completion
    }

    public func onAppear() {
        guard tasks.isEmpty else { return }
        loadTask?.cancel()
        loadTask = _Concurrency.Task { [dependencies, prefill] in
            do {
                let active = try await dependencies.taskQueryClient.fetchActiveTasks()
                let done = try await dependencies.taskQueryClient.fetchTasksByStatus(.done)
                var allTasks = active + done
                if let taskId = prefill?.taskId,
                   !allTasks.contains(where: { $0.id == taskId }),
                   let task = try await dependencies.taskQueryClient.fetchTask(taskId) {
                    allTasks.append(task)
                }
                tasksResponse(allTasks)
            } catch {
                tasksResponse([])
            }
        }
    }

    public func taskSelected(_ task: Domain.Task) {
        selectedTaskID = task.id
        selectedVisibility = task.visibility
    }

    public func imageSelected(_ image: UIImage) {
        selectedImage = image
        imagePaths = ["선택한 사진"]
    }

    public func removeImage(_ path: String) {
        imagePaths.removeAll { $0 == path }
        if imagePaths.isEmpty {
            selectedImage = nil
        }
    }

    public func submitTapped() {
        guard canSubmit else { return }
        isSaving = true
        let postID = BragPostID(UUID())
        let selectedTaskID = selectedTaskID
        let selectedVisibility = selectedVisibility
        let selectedImage = selectedImage
        let body = trimmedBody
        let type = suggestedType
        let currentUserID = currentUserID

        _Concurrency.Task { [dependencies] in
            do {
                let storedImagePaths: [String]
                if let selectedImage {
                    let data = try makeImageStoreInputData(from: selectedImage)
                    let key = "brag-\(postID.rawValue.uuidString)-1.jpg"
                    storedImagePaths = [try await dependencies.imageStore.saveImage(key, data)]
                } else {
                    storedImagePaths = []
                }
                let post = Domain.BragPost(
                    id: postID,
                    authorId: currentUserID,
                    taskId: selectedTaskID,
                    type: type,
                    body: body,
                    recordImagePaths: storedImagePaths,
                    visibility: selectedVisibility
                )
                try await dependencies.bragPostRepository.createPost(post)
                isSaving = false
                onCompleted()
            } catch {
                isSaving = false
                toastMessage = "공유하지 못했어요"
            }
        }
    }

    public func dismissToast() {
        toastMessage = nil
    }

    private func tasksResponse(_ tasks: [Domain.Task]) {
        self.tasks = tasks
        if let selectedTaskID,
           let task = tasks.first(where: { $0.id == selectedTaskID }) {
            taskSelected(task)
        } else if selectedTaskID == nil, let first = tasks.first {
            taskSelected(first)
        }
    }
}
