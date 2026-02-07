import Foundation
import ComposableArchitecture

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
        public init() {}
    }

    public enum Action: Equatable {
        case useCaseButtonTapped
        case inquiryButtonTapped
        case reviewButtonTapped
        case licenceButtonTapped
        case loadNotificationSettings
        case notificationToggleChanged(Bool)
        case notificationSettingsResponse(Bool)
        case themeChanged(ThemeMode)
        
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case navigateToWalkThrough
            case presentMailCompose
            case openReviewURL
            case navigateToLicence
        }
    }

    @Dependency(\.notificationScheduler) var notificationScheduler
    @Dependency(\.userSettingsRepository) var userSettingsRepository
    @Dependency(\.appPreferences) var appPreferences

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
                if let raw = appPreferences.getThemeModeRaw(),
                   let mode = ThemeMode(rawValue: raw) {
                    state.theme = mode
                }
                state.isLoading = true
                return .run { [userSettingsRepository] send in
                    let isEnabled = await userSettingsRepository.isNotificationEnabled()
                    await send(.notificationSettingsResponse(isEnabled))
                }
            case let .notificationToggleChanged(isEnabled):
                state.isNotificationEnabled = isEnabled
                state.isLoading = true
                return .run { [notificationScheduler, userSettingsRepository] send in
                    let reminderUseCase = ReminderSchedulingUseCase()
                    let reminders = await userSettingsRepository.getAllReminders()
                    await reminderUseCase.syncGlobalReminders(
                        isEnabled: isEnabled,
                        reminders: reminders,
                        notificationScheduler: notificationScheduler
                    )
                    await userSettingsRepository.updateNotificationEnabled(isEnabled)
                    await send(.notificationSettingsResponse(isEnabled))
                }
            case let .notificationSettingsResponse(isEnabled):
                state.isNotificationEnabled = isEnabled
                state.isLoading = false
                return .none
            case let .themeChanged(mode):
                state.theme = mode
                appPreferences.setThemeModeRaw(mode.rawValue)
                NotificationCenter.default.post(name: .jacsimThemeChanged, object: nil)
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
