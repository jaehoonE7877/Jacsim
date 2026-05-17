import Foundation
import Domain
import Observation

public enum ThemeMode: String, Equatable, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
}

@MainActor
@Observable
public final class SettingScreenModel {
    public struct PendingFollowRequestRow: Identifiable {
        public let follow: Follow
        public let user: Domain.User

        public var id: UUID { follow.id.rawValue }
    }

    public var version: String
    public var isNotificationEnabled: Bool = false
    public var isLoading: Bool = false
    public var notificationPermissionDenied: Bool = false
    public var theme: ThemeMode = .system
    public var wallpaperRaw: String = "morning"
    public var pendingFollowRequests: [PendingFollowRequestRow] = []
    public var acceptFeedbackTrigger: Int = 0

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
            let wallpaper = await dependencies.userSettingsRepository.wallpaperRaw()
            let pending = (try? await dependencies.followRepository.fetchPendingRequests(SocialLocalSession.currentUserID)) ?? []
            var rows: [PendingFollowRequestRow] = []
            for follow in pending {
                if let user = try? await dependencies.socialUserRepository.fetchUser(follow.fromUserId) {
                    rows.append(PendingFollowRequestRow(follow: follow, user: user))
                }
            }
            pendingFollowRequestsResponse(rows)
            wallpaperSettingsResponse(wallpaper)
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

    public func wallpaperChanged(_ rawValue: String) {
        wallpaperRaw = rawValue
        settingsTask?.cancel()
        settingsTask = _Concurrency.Task { [dependencies] in
            await dependencies.userSettingsRepository.updateWallpaperRaw(rawValue)
        }
    }

    public func acceptFollowRequest(_ row: PendingFollowRequestRow) {
        acceptFeedbackTrigger += 1
        updateFollowRequest(row, state: .accepted)
    }

    public func rejectFollowRequest(_ row: PendingFollowRequestRow) {
        updateFollowRequest(row, state: .rejected)
    }

    private func updateFollowRequest(_ row: PendingFollowRequestRow, state: FollowState) {
        var follow = row.follow
        follow.state = state
        follow.respondedAt = .now
        let acceptedContext = SocialNotificationContext(
            sourceUserId: SocialLocalSession.currentUserID,
            targetUserId: row.follow.fromUserId,
            title: "친구 요청 수락",
            body: "친구 요청이 수락되었어요"
        )
        settingsTask?.cancel()
        settingsTask = _Concurrency.Task { [dependencies] in
            do {
                try await dependencies.followRepository.upsertFollow(follow)
                if state == .accepted,
                   SocialLocalSession.shouldScheduleLocalNotification(
                    sourceUserID: acceptedContext.sourceUserId,
                    targetUserID: acceptedContext.targetUserId
                   ) {
                    try? await dependencies.notificationScheduler.scheduleSocial(
                        .followAccepted,
                        acceptedContext
                    )
                }
                loadNotificationSettings()
            } catch {
                pendingFollowRequests.removeAll { $0.id == row.id }
            }
        }
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

    private func wallpaperSettingsResponse(_ rawValue: String) {
        wallpaperRaw = rawValue
    }

    private func pendingFollowRequestsResponse(_ rows: [PendingFollowRequestRow]) {
        pendingFollowRequests = rows
    }
}
