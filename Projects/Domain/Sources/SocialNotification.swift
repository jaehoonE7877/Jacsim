import Foundation

public enum SocialNotificationTrigger: String, Codable, Sendable, CaseIterable, Identifiable {
    case followRequested
    case followAccepted
    case friendPosted
    case friendGraduated
    case postCheered
    case postFollowed
    case postCommented
    case coachWeekly

    public var id: String { rawValue }
}

public struct SocialNotificationContext: Codable, Sendable, Equatable {
    public var sourceUserId: UserID?
    public var targetUserId: UserID?
    public var postId: BragPostID?
    public var taskId: TaskID?
    public var title: String
    public var body: String

    public init(
        sourceUserId: UserID? = nil,
        targetUserId: UserID? = nil,
        postId: BragPostID? = nil,
        taskId: TaskID? = nil,
        title: String,
        body: String
    ) {
        self.sourceUserId = sourceUserId
        self.targetUserId = targetUserId
        self.postId = postId
        self.taskId = taskId
        self.title = title
        self.body = body
    }
}

public struct SocialNotificationKey: Codable, Sendable, Hashable {
    public let trigger: SocialNotificationTrigger
    public let rawValue: String

    public init(trigger: SocialNotificationTrigger, rawValue: String) {
        self.trigger = trigger
        self.rawValue = rawValue
    }
}

public struct SocialNotificationSettings: Codable, Sendable, Equatable {
    public var followRequested: Bool
    public var followAccepted: Bool
    public var friendPosted: Bool
    public var friendGraduated: Bool
    public var postCheered: Bool
    public var postFollowed: Bool
    public var postCommented: Bool
    public var coachWeekly: Bool
    public var coachWeeklyHour: Int
    public var coachWeeklyMinute: Int
    public var coachWeeklyWeekday: Int

    public init(
        followRequested: Bool = true,
        followAccepted: Bool = true,
        friendPosted: Bool = false,
        friendGraduated: Bool = true,
        postCheered: Bool = true,
        postFollowed: Bool = true,
        postCommented: Bool = true,
        coachWeekly: Bool = true,
        coachWeeklyHour: Int = 20,
        coachWeeklyMinute: Int = 0,
        coachWeeklyWeekday: Int = 1
    ) {
        self.followRequested = followRequested
        self.followAccepted = followAccepted
        self.friendPosted = friendPosted
        self.friendGraduated = friendGraduated
        self.postCheered = postCheered
        self.postFollowed = postFollowed
        self.postCommented = postCommented
        self.coachWeekly = coachWeekly
        self.coachWeeklyHour = coachWeeklyHour
        self.coachWeeklyMinute = coachWeeklyMinute
        self.coachWeeklyWeekday = coachWeeklyWeekday
    }

    public func isEnabled(_ trigger: SocialNotificationTrigger) -> Bool {
        switch trigger {
        case .followRequested:
            return followRequested
        case .followAccepted:
            return followAccepted
        case .friendPosted:
            return friendPosted
        case .friendGraduated:
            return friendGraduated
        case .postCheered:
            return postCheered
        case .postFollowed:
            return postFollowed
        case .postCommented:
            return postCommented
        case .coachWeekly:
            return coachWeekly
        }
    }

    public mutating func setEnabled(_ enabled: Bool, for trigger: SocialNotificationTrigger) {
        switch trigger {
        case .followRequested:
            followRequested = enabled
        case .followAccepted:
            followAccepted = enabled
        case .friendPosted:
            friendPosted = enabled
        case .friendGraduated:
            friendGraduated = enabled
        case .postCheered:
            postCheered = enabled
        case .postFollowed:
            postFollowed = enabled
        case .postCommented:
            postCommented = enabled
        case .coachWeekly:
            coachWeekly = enabled
        }
    }
}

public protocol SocialNotificationScheduling: Sendable {
    func scheduleSocial(trigger: SocialNotificationTrigger, context: SocialNotificationContext) async throws
}

public struct NotificationTriggerService: Sendable {
    public init() {}

    public func scheduleIfEnabled(
        trigger: SocialNotificationTrigger,
        context: SocialNotificationContext,
        settings: SocialNotificationSettings,
        scheduler: any SocialNotificationScheduling
    ) async throws {
        guard settings.isEnabled(trigger) else { return }
        try await scheduler.scheduleSocial(trigger: trigger, context: context)
    }
}

