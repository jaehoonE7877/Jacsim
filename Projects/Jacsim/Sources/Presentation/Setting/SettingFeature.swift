import Foundation
import Observation

public enum ThemeMode: String, Equatable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
}

@MainActor
@Observable
public final class SettingScreenModel {
    public var version: String
    public var isNotificationEnabled: Bool = false
    public var isLoading: Bool = false
    public var notificationPermissionDenied: Bool = false
    public var theme: ThemeMode = .system

    @ObservationIgnored public let dependencies: JacsimDependencies
    @ObservationIgnored private var settingsTask: _Concurrency.Task<Void, Never>?

    public init(
        dependencies: JacsimDependencies,
        version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "2.0.0"
    ) {
        self.dependencies = dependencies
        self.version = version
    }

    deinit {
        settingsTask?.cancel()
    }

    public func loadNotificationSettings() {
        if let raw = dependencies.appPreferences.getThemeModeRaw(),
           let mode = ThemeMode(rawValue: raw) {
            theme = mode
        }
        isLoading = true
        settingsTask?.cancel()
        settingsTask = _Concurrency.Task { [dependencies] in
            let isEnabled = await dependencies.userSettingsRepository.isNotificationEnabled()
            notificationSettingsResponse(isEnabled)
        }
    }

    public func notificationToggleChanged(_ isEnabled: Bool) {
        isNotificationEnabled = isEnabled
        isLoading = true
        notificationPermissionDenied = false
        settingsTask?.cancel()
        settingsTask = _Concurrency.Task { [dependencies] in
            if isEnabled {
                do {
                    let granted = try await dependencies.notificationScheduler.requestAuthorization()
                    guard granted else {
                        await dependencies.userSettingsRepository.updateNotificationEnabled(false)
                        notificationPermissionDeniedResponse()
                        return
                    }
                } catch {
                    await dependencies.userSettingsRepository.updateNotificationEnabled(false)
                    notificationPermissionDeniedResponse()
                    return
                }
            }

            let reminderUseCase = ReminderSchedulingUseCase()
            let reminders = await dependencies.userSettingsRepository.getAllReminders()
            await reminderUseCase.syncGlobalReminders(
                isEnabled: isEnabled,
                reminders: reminders,
                notificationScheduler: dependencies.notificationScheduler
            )
            await dependencies.userSettingsRepository.updateNotificationEnabled(isEnabled)
            notificationSettingsResponse(isEnabled)
        }
    }

    public func themeChanged(_ mode: ThemeMode) {
        theme = mode
        dependencies.appPreferences.setThemeModeRaw(mode.rawValue)
        NotificationCenter.default.post(name: .jacsimThemeChanged, object: nil)
    }

    private func notificationSettingsResponse(_ isEnabled: Bool) {
        isNotificationEnabled = isEnabled
        isLoading = false
    }

    private func notificationPermissionDeniedResponse() {
        isNotificationEnabled = false
        isLoading = false
        notificationPermissionDenied = true
    }
}
