import Foundation
import ExternalInterface

public struct GlobalNotificationSettingUseCase: Sendable {
    public enum Outcome: Sendable, Equatable {
        case enabled
        case disabled
        case permissionDenied
        case permissionError
    }

    public var setEnabled: @Sendable (Bool) async -> Outcome

    public init(setEnabled: @escaping @Sendable (Bool) async -> Outcome) {
        self.setEnabled = setEnabled
    }
}

extension GlobalNotificationSettingUseCase {
    static func live(
        userSettingsRepository: UserSettingsRepositoryPort,
        notificationScheduler: NotificationSchedulerPort,
        reminderSchedulingUseCase: ReminderSchedulingUseCase
    ) -> Self {
        Self(
            setEnabled: { isEnabled in
                if !isEnabled {
                    await reminderSchedulingUseCase.syncGlobalReminders(isEnabled: false)
                    await userSettingsRepository.updateNotificationEnabled(false)
                    return .disabled
                }

                do {
                    let granted = try await notificationScheduler.requestAuthorization()
                    guard granted else {
                        return .permissionDenied
                    }
                } catch {
                    return .permissionError
                }

                await reminderSchedulingUseCase.syncGlobalReminders(isEnabled: true)
                await userSettingsRepository.updateNotificationEnabled(true)
                return .enabled
            }
        )
    }
}
