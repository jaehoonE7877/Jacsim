import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class AllTaskModel {
    public var ongoingTasks: [Domain.Task] = []
    public var successTasks: [Domain.Task] = []
    public var failTasks: [Domain.Task] = []
    public var isLoading: Bool = false
    public var loadFailed: Bool = false
    public var isOngoingExpanded: Bool = true
    public var isSuccessExpanded: Bool = true
    public var isFailExpanded: Bool = true

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private let onTaskTapped: (Domain.Task) -> Void
    @ObservationIgnored private var loadTask: _Concurrency.Task<Void, Never>?

    public init(
        dependencies: JacsimDependencies,
        onTaskTapped: @escaping (Domain.Task) -> Void = { _ in }
    ) {
        self.dependencies = dependencies
        self.onTaskTapped = onTaskTapped
    }

    deinit {
        loadTask?.cancel()
    }

    public func loadTasks() {
        isLoading = true
        loadFailed = false
        loadTask?.cancel()
        loadTask = _Concurrency.Task { [dependencies] in
            do {
                let ongoing = try await dependencies.taskQueryClient.fetchActiveTasks()
                let success = try await dependencies.taskQueryClient.fetchIsSuccess()
                let fail = try await dependencies.taskQueryClient.fetchIsFail()
                tasksResponse(ongoing: ongoing, success: success, fail: fail)
            } catch {
                tasksLoadFailed()
            }
        }
    }

    public func toggleOngoing() {
        isOngoingExpanded.toggle()
    }

    public func toggleSuccess() {
        isSuccessExpanded.toggle()
    }

    public func toggleFail() {
        isFailExpanded.toggle()
    }

    public func taskTapped(_ task: Domain.Task) {
        onTaskTapped(task)
    }

    private func tasksResponse(
        ongoing: [Domain.Task],
        success: [Domain.Task],
        fail: [Domain.Task]
    ) {
        ongoingTasks = ongoing
        successTasks = success
        failTasks = fail
        isLoading = false
        loadFailed = false
    }

    private func tasksLoadFailed() {
        isLoading = false
        loadFailed = true
    }
}
