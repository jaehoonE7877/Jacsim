import Core
import Domain
import Foundation
import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
public final class TaskEditModel: Identifiable {
    public nonisolated let id: TaskID
    public var task: Task
    public var title: String {
        didSet { enforceTitleLimit() }
    }
    public var lastAcceptedTitle: String
    public var image: UIImage?
    public var isAlarmEnabled: Bool
    public var alarmDate: Date
    public var toastMessage: String?

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private let onSaved: (String, UIImage?, Bool, Date) -> Void
    @ObservationIgnored private let onCancelled: () -> Void
    @ObservationIgnored private var loadImageTask: _Concurrency.Task<Void, Never>?
    @ObservationIgnored private var isEnforcingTitle = false

    public init(
        task: Task,
        dependencies: JacsimDependencies,
        onSaved: @escaping (String, UIImage?, Bool, Date) -> Void = { _, _, _, _ in },
        onCancelled: @escaping () -> Void = {}
    ) {
        self.id = task.id
        self.task = task
        self.title = task.title
        self.lastAcceptedTitle = task.title
        self.isAlarmEnabled = task.isNotificationEnabled
        self.alarmDate = task.alarm ?? Date()
        self.dependencies = dependencies
        self.onSaved = onSaved
        self.onCancelled = onCancelled
    }

    deinit {
        loadImageTask?.cancel()
    }

    public func onAppear() {
        let key = task.mainImageKey
        loadImageTask?.cancel()
        loadImageTask = _Concurrency.Task { [dependencies] in
            let imageData = await dependencies.imageStore.loadImage(key)
            let image = imageData.flatMap { UIImage(data: $0) }
            imageLoaded(image)
        }
    }

    public func saveButtonTapped() {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        onSaved(title, image, isAlarmEnabled, alarmDate)
    }

    public func cancelButtonTapped() {
        onCancelled()
    }

    public func imageSelected(_ image: UIImage) {
        self.image = image
    }

    public func toastDismissed() {
        toastMessage = nil
    }

    private func imageLoaded(_ image: UIImage?) {
        self.image = image
    }

    private func enforceTitleLimit() {
        guard !isEnforcingTitle else { return }
        let result = TextInputLimiter.enforce(
            previousAcceptedText: lastAcceptedTitle,
            candidateText: title,
            policy: .title
        )
        isEnforcingTitle = true
        switch result {
        case let .accepted(text):
            title = text
            lastAcceptedTitle = text
        case let .rejected(keep):
            title = keep
            toastMessage = TextInputFieldPolicy.title.exceededToastMessage
        }
        isEnforcingTitle = false
    }
}
