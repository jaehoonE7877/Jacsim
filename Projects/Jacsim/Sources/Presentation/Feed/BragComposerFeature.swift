import Domain
import Foundation
import Observation
import UIKit

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
    @ObservationIgnored private var loadTask: _Concurrency.Task<Void, Never>?

    private let currentUserID = SocialLocalSession.currentUserID

    public init(
        dependencies: JacsimDependencies,
        onCompleted: @escaping () -> Void = {}
    ) {
        self.dependencies = dependencies
        self.onCompleted = onCompleted
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
        loadTask = _Concurrency.Task { [dependencies] in
            do {
                let active = try await dependencies.taskQueryClient.fetchActiveTasks()
                let done = try await dependencies.taskQueryClient.fetchTasksByStatus(.done)
                tasksResponse(active + done)
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
        appendImagePath("photo-\(imagePaths.count + 1).jpg")
    }

    public func sampleImageTapped() {
        appendImagePath("sample-\(imagePaths.count + 1).jpg")
    }

    public func removeImage(_ path: String) {
        imagePaths.removeAll { $0 == path }
    }

    public func submitTapped() {
        guard canSubmit else { return }
        isSaving = true
        let post = Domain.BragPost(
            id: BragPostID(UUID()),
            authorId: currentUserID,
            taskId: selectedTaskID,
            type: suggestedType,
            body: trimmedBody,
            recordImagePaths: imagePaths
        )

        _Concurrency.Task { [dependencies] in
            do {
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

    private func appendImagePath(_ path: String) {
        guard imagePaths.count < 4 else {
            toastMessage = "사진은 최대 4장까지"
            return
        }
        imagePaths.append(path)
    }

    private func tasksResponse(_ tasks: [Domain.Task]) {
        self.tasks = tasks
        if selectedTaskID == nil, let first = tasks.first {
            taskSelected(first)
        }
    }
}
