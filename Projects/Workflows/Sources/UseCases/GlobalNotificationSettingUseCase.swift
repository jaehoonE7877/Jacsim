import Foundation
import Ports

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
    public static func live(
        userSettingsRepository: UserSettingsRepositoryPort,
        notificationScheduler: NotificationSchedulerPort,
        reminderSchedulingUseCase: ReminderSchedulingUseCase
    ) -> Self {
        Self(
            setEnabled: { isEnabled in
                if !isEnabled {
                    await userSettingsRepository.updateNotificationEnabled(false)
                    await reminderSchedulingUseCase.syncGlobalReminders(isEnabled: false)
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

                await userSettingsRepository.updateNotificationEnabled(true)
                await reminderSchedulingUseCase.syncGlobalReminders(isEnabled: true)
                return .enabled
            }
        )
    }
}
