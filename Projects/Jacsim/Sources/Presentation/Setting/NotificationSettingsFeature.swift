import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class NotificationSettingsModel {
    public var settings = SocialNotificationSettings()
    public var isLoading = false

    @ObservationIgnored private let dependencies: JacsimDependencies
    @ObservationIgnored private var settingsTask: _Concurrency.Task<Void, Never>?

    public init(dependencies: JacsimDependencies) {
        self.dependencies = dependencies
    }

    deinit {
        settingsTask?.cancel()
    }

    public var coachWeeklyTime: Date {
        get {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = settings.coachWeeklyHour
            components.minute = settings.coachWeeklyMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            settings.coachWeeklyHour = components.hour ?? 20
            settings.coachWeeklyMinute = components.minute ?? 0
            persist()
        }
    }

    public func onAppear() {
        guard !isLoading else { return }
        isLoading = true
        settingsTask?.cancel()
        settingsTask = _Concurrency.Task { [dependencies] in
            let loaded = await dependencies.userSettingsRepository.socialNotificationSettings()
            settingsResponse(loaded)
        }
    }

    public func isEnabled(_ trigger: SocialNotificationTrigger) -> Bool {
        settings.isEnabled(trigger)
    }

    public func setEnabled(_ enabled: Bool, for trigger: SocialNotificationTrigger) {
        settings.setEnabled(enabled, for: trigger)
        persist()
    }

    public func weekdayChanged(_ weekday: Int) {
        settings.coachWeeklyWeekday = weekday
        persist()
    }

    private func persist() {
        let settings = settings
        settingsTask?.cancel()
        settingsTask = _Concurrency.Task { [dependencies] in
            await dependencies.userSettingsRepository.updateSocialNotificationSettings(settings)
            if settings.coachWeekly {
                try? await dependencies.notificationScheduler.scheduleSocial(
                    .coachWeekly,
                    SocialNotificationContext(
                        title: "AI 코치 주간 회고",
                        body: "이번 주 작심 흐름을 돌아볼 시간이에요"
                    )
                )
            } else {
                try? await dependencies.notificationScheduler.cancelSocial(SocialNotificationKey(trigger: .coachWeekly, rawValue: "weekly"))
            }
        }
    }

    private func settingsResponse(_ loaded: SocialNotificationSettings) {
        settings = loaded
        isLoading = false
    }
}
