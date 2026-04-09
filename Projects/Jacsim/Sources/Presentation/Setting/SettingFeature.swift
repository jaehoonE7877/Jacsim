import Foundation
import ComposableArchitecture
import UIKit
import JacsimClient

public enum ThemeMode: String, Equatable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
}

@Reducer
public struct SettingFeature {
    public enum NotificationBanner: Equatable {
        case permissionDenied
        case permissionError
    }

    @ObservableState
    public struct State: Equatable {
        public var version: String
        public var isNotificationEnabled: Bool = false
        public var isLoading: Bool = false
        public var theme: ThemeMode = .system
        public var notificationBanner: NotificationBanner? = nil

        public init() {
            version = Bundle.main.shortVersionString
        }
    }

    public enum Action: Equatable {
        case useCaseButtonTapped
        case inquiryButtonTapped
        case reviewButtonTapped
        case licenceButtonTapped
        case loadNotificationSettings
        case notificationToggleChanged(Bool)
        case notificationSettingsResponse(Bool)
        case notificationPermissionDenied
        case notificationPermissionError
        case notificationBannerDismissed
        case openSystemSettingsTapped
        case themeChanged(ThemeMode)
        
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case navigateToWalkThrough
            case presentMailCompose
            case openReviewURL
            case navigateToLicence
        }
    }

    @Dependency(\.userSettingsRepository) var userSettingsRepository
    @Dependency(\.appPreferences) var appPreferences
    @Dependency(\.globalNotificationSettingUseCase) var globalNotificationSettingUseCase

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
                state.notificationBanner = nil

                state.isLoading = true
                return .run { [userSettingsRepository] send in
                    let isEnabled = await userSettingsRepository.isNotificationEnabled()
                    await send(.notificationSettingsResponse(isEnabled))
                }
            case let .notificationToggleChanged(isEnabled):
                state.isNotificationEnabled = isEnabled
                state.isLoading = true
                state.notificationBanner = nil

                return .run { [globalNotificationSettingUseCase] send in
                    let outcome = await globalNotificationSettingUseCase.setEnabled(isEnabled)
                    switch outcome {
                    case .enabled:
                        await send(.notificationSettingsResponse(true))
                    case .disabled:
                        await send(.notificationSettingsResponse(false))
                    case .permissionDenied:
                        await send(.notificationSettingsResponse(false))
                        await send(.notificationPermissionDenied)
                    case .permissionError:
                        await send(.notificationSettingsResponse(false))
                        await send(.notificationPermissionError)
                    }
                }

            case .notificationPermissionDenied:
                state.notificationBanner = .permissionDenied
                return .none

            case .notificationPermissionError:
                state.notificationBanner = .permissionError
                return .none

            case .notificationBannerDismissed:
                state.notificationBanner = nil
                return .none

            case .openSystemSettingsTapped:
                return .run { _ in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    await MainActor.run {
                        UIApplication.shared.open(url)
                    }
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

private extension Bundle {
    var shortVersionString: String {
        (object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        ?? (object(forInfoDictionaryKey: "CFBundleVersion") as? String)
        ?? ""
    }
}
