import Foundation
import SwiftData
import ComposableArchitecture
import Data
import Domain

@Reducer
public struct SettingFeature {
    @ObservableState
    public struct State: Equatable {
        public var version: String = "1.0.0"
        public var isNotificationEnabled: Bool = false
        public var isLoading: Bool = false
        public init() {}
    }

    public enum Action {
        case useCaseButtonTapped
        case inquiryButtonTapped
        case reviewButtonTapped
        case licenceButtonTapped
        case loadNotificationSettings
        case notificationToggleChanged(Bool)
        case notificationSettingsResponse(Bool)
        
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
                return .run { send in
                    let isEnabled = await MainActor.run {
                        let context = SwiftDataStack.shared.context
                        let descriptor = FetchDescriptor<UserJacsimModel>()
                        let results = (try? context.fetch(descriptor)) ?? []
                        return results.contains { $0.isNotificationEnabled }
                    }
                    await send(.notificationSettingsResponse(isEnabled))
                }
            case let .notificationToggleChanged(isEnabled):
                state.isNotificationEnabled = isEnabled
                state.isLoading = true
                return .run { [notificationScheduler] send in
                    let reminders = await MainActor.run { () -> [(TaskID, String, DateComponents)] in
                        let context = SwiftDataStack.shared.context
                        let descriptor = FetchDescriptor<UserJacsimModel>()
                        let results = (try? context.fetch(descriptor)) ?? []
                        results.forEach { $0.isNotificationEnabled = isEnabled }
                        try? context.save()
                        return results.compactMap { model in
                            guard let alarm = model.alarm else { return nil }
                            let time = Calendar.current.dateComponents([.hour, .minute], from: alarm)
                            return (TaskID(model.id), model.title, time)
                        }
                    }

                    if isEnabled {
                        for reminder in reminders {
                            try? await notificationScheduler.scheduleDailyReminder(reminder.0, reminder.1, reminder.2)
                        }
                    } else {
                        for reminder in reminders {
                            await notificationScheduler.cancelReminder(reminder.0)
                        }
                    }
                    await send(.notificationSettingsResponse(isEnabled))
                }
            case let .notificationSettingsResponse(isEnabled):
                state.isNotificationEnabled = isEnabled
                state.isLoading = false
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
