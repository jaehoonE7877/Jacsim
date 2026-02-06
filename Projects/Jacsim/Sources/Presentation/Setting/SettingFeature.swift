import Foundation
import ComposableArchitecture
import Domain

public enum ThemeMode: String, Equatable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
}

@Reducer
public struct SettingFeature {
    @ObservableState
    public struct State: Equatable {
        public var version: String = "1.0.0"
        public var isNotificationEnabled: Bool = false
        public var isLoading: Bool = false
        public var theme: ThemeMode = .system
        public init() {
            if let raw = UserDefaults.standard.string(forKey: "appearance_theme"),
               let mode = ThemeMode(rawValue: raw) {
                self.theme = mode
            }
        }
    }

    public enum Action {
        case useCaseButtonTapped
        case inquiryButtonTapped
        case reviewButtonTapped
        case licenceButtonTapped
        case loadNotificationSettings
        case notificationToggleChanged(Bool)
        case notificationSettingsResponse(Bool)
        case themeChanged(ThemeMode)
        
        case delegate(Delegate)
        public enum Delegate {
            case navigateToWalkThrough
            case presentMailCompose
            case openReviewURL
            case navigateToLicence
        }
    }

    @Dependency(\.notificationScheduler) var notificationScheduler
    @Dependency(\.jacsimClient) var jacsimClient
    @Dependency(\.userSettingsRepository) var userSettingsRepository

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .useCaseButtonTapped:
                return .send(.delegate(.navigateToWalkThrough))
            case .inquiryButtonTapped:
                return .send(.delegate(.presentMailCompose))
            case .reviewButtonTapped:
                return .send(.delegate(.openReviewURL))
            case .licenceButtonTapped:
                return .send(.delegate(.navigateToLicence))
            case .loadNotificationSettings:
                state.isLoading = true
                return .run { [userSettingsRepository] send in
                    let isEnabled = await userSettingsRepository.isNotificationEnabled()
                    await send(.notificationSettingsResponse(isEnabled))
                }
            case let .notificationToggleChanged(isEnabled):
                state.isNotificationEnabled = isEnabled
                state.isLoading = true
                return .run { [notificationScheduler, userSettingsRepository] send in
                    await userSettingsRepository.updateNotificationEnabled(isEnabled)
                    let reminders = await userSettingsRepository.getAllReminders()

                    if isEnabled {
                        for reminder in reminders {
                            try? await notificationScheduler.scheduleDailyReminder(reminder.taskId, reminder.title, reminder.time)
                        }
                    } else {
                        for reminder in reminders {
                            await notificationScheduler.cancelReminder(reminder.taskId)
                        }
                    }
                    await send(.notificationSettingsResponse(isEnabled))
                }
            case let .notificationSettingsResponse(isEnabled):
                state.isNotificationEnabled = isEnabled
                state.isLoading = false
                return .none
            case let .themeChanged(mode):
                state.theme = mode
                UserDefaults.standard.set(mode.rawValue, forKey: "appearance_theme")
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
