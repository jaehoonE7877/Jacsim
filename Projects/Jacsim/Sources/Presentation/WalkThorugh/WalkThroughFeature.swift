import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
public final class WalkThroughModel {
    public var currentPage: Int = 0
    public var fromSetting: Bool
    public let totalPages: Int = 4
    public var notificationPermissionStatus: UNAuthorizationStatus?

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private let onCompleteOnboarding: () -> Void

    public init(
        fromSetting: Bool,
        dependencies: JacsimDependencies,
        onCompleteOnboarding: @escaping () -> Void = {}
    ) {
        self.fromSetting = fromSetting
        self.dependencies = dependencies
        self.onCompleteOnboarding = onCompleteOnboarding
    }

    public func continueButtonTapped() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        } else {
            onCompleteOnboarding()
        }
    }

    public func skipButtonTapped() {
        onCompleteOnboarding()
    }

    public func requestNotificationPermission() {
        if notificationPermissionStatus == .denied || notificationPermissionStatus == .authorized {
            continueButtonTapped()
            return
        }

        _Concurrency.Task { [dependencies] in
            do {
                let granted = try await dependencies.notificationScheduler.requestAuthorization()
                notificationPermissionResponse(granted)
            } catch {
                notificationPermissionResponse(false)
            }
        }
    }

    private func notificationPermissionResponse(_ granted: Bool) {
        notificationPermissionStatus = granted ? .authorized : .denied
        if granted, currentPage < totalPages - 1 {
            currentPage += 1
        }
    }
}
