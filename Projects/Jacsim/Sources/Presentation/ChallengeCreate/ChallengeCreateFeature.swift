import Foundation
import Observation

@MainActor
@Observable
public final class ChallengeCreateModel: Identifiable {
    public let id = UUID()
    public let newTask: NewTaskModel

    @ObservationIgnored private let onChallengeCreated: () -> Void
    @ObservationIgnored private let onCancelled: () -> Void

    public init(
        dependencies: JacsimDependencies,
        onChallengeCreated: @escaping () -> Void = {},
        onCancelled: @escaping () -> Void = {}
    ) {
        self.onChallengeCreated = onChallengeCreated
        self.onCancelled = onCancelled
        self.newTask = NewTaskModel(
            dependencies: dependencies,
            onTaskCreated: onChallengeCreated,
            onCancelled: onCancelled
        )
    }

    public func cancelButtonTapped() {
        onCancelled()
    }
}
