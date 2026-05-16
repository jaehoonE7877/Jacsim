import Foundation
import Observation

public enum AppScreen {
    case onboarding(WalkThroughModel)
    case main(MainModel)
}

public enum AppScreenKind: Equatable {
    case onboarding
    case main
}

@MainActor
@Observable
public final class AppModel {
    public var screen: AppScreen

    @ObservationIgnored public let dependencies: JacsimDependencies
    @ObservationIgnored private var reminderSyncTask: _Concurrency.Task<Void, Never>?

    public init(dependencies: JacsimDependencies = .live) {
        self.dependencies = dependencies
        self.screen = .onboarding(
            WalkThroughModel(fromSetting: false, dependencies: dependencies)
        )
        self.screen = .onboarding(makeOnboardingModel())
    }

    deinit {
        reminderSyncTask?.cancel()
    }

    public var screenKind: AppScreenKind {
        switch screen {
        case .onboarding:
            return .onboarding
        case .main:
            return .main
        }
    }

    public var homeIsFetching: Bool {
        guard case let .main(mainModel) = screen else { return false }
        return mainModel.home.isFetching
    }

    public func onAppear() {
        _Concurrency.Task { [dependencies] in
            await dependencies.seedSocialIfNeeded()
        }

        let isOnboardingCompleted = dependencies.appPreferences.isOnboardingCompleted()

        switch (isOnboardingCompleted, screen) {
        case (true, .main), (false, .onboarding):
            break
        case (true, _):
            screen = .main(MainModel(dependencies: dependencies))
        case (false, _):
            screen = .onboarding(makeOnboardingModel())
        }

        appBecameActive()
    }

    public func appBecameActive() {
        reminderSyncTask?.cancel()
        reminderSyncTask = _Concurrency.Task { [dependencies] in
            let isNotificationEnabled = await dependencies.userSettingsRepository.isNotificationEnabled()
            let reminders = await dependencies.userSettingsRepository.getAllReminders()
            let reminderUseCase = ReminderSchedulingUseCase()
            await reminderUseCase.syncGlobalReminders(
                isEnabled: isNotificationEnabled,
                reminders: reminders,
                notificationScheduler: dependencies.notificationScheduler
            )
        }
    }

    private func completeOnboarding() {
        dependencies.appPreferences.setOnboardingCompleted(true)
        screen = .main(MainModel(dependencies: dependencies))
    }

    private func makeOnboardingModel() -> WalkThroughModel {
        WalkThroughModel(
            fromSetting: false,
            dependencies: dependencies,
            onCompleteOnboarding: { [weak self] in
                self?.completeOnboarding()
            }
        )
    }
}
