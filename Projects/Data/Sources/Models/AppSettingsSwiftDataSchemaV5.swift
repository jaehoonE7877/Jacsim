import Foundation
import SwiftData

// Current app settings model. The schema version stays V5 for migration compatibility.
public enum JacsimSchemaV5: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        Schema.Version(5, 0, 0)
    }

    public static var models: [any PersistentModel.Type] {
        [
            JacsimSchemaV3.UserJacsimModel.self,
            AppSettingsModel.self,
            JacsimSchemaV3.CertifiedModel.self,
            JacsimSchemaV3.StageModel.self,
            JacsimSchemaV3.UserModel.self,
            JacsimSchemaV3.FollowModel.self,
            JacsimSchemaV3.BragPostModel.self,
            JacsimSchemaV3.CheerModel.self,
            JacsimSchemaV3.CommentModel.self,
            JacsimSchemaV3.FollowChallengeModel.self
        ]
    }

    @Model
    public final class AppSettingsModel {
        @Attribute(.unique) public var id: String
        public var isNotificationEnabled: Bool
        public var wallpaperRaw: String?
        public var seededSocialV1: Bool?
        public var notifyFollowRequested: Bool?
        public var notifyFollowAccepted: Bool?
        public var notifyFriendPosted: Bool?
        public var notifyFriendGraduated: Bool?
        public var notifyPostCheered: Bool?
        public var notifyPostFollowed: Bool?
        public var notifyPostCommented: Bool?
        public var notifyCoachWeekly: Bool?
        public var coachWeeklyHour: Int?
        public var coachWeeklyMinute: Int?
        public var coachWeeklyWeekday: Int?
        public var widgetMigrationV1Done: Bool?

        public init(
            id: String = "global",
            isNotificationEnabled: Bool = false,
            wallpaperRaw: String? = "morning",
            seededSocialV1: Bool? = false,
            notifyFollowRequested: Bool? = true,
            notifyFollowAccepted: Bool? = true,
            notifyFriendPosted: Bool? = false,
            notifyFriendGraduated: Bool? = true,
            notifyPostCheered: Bool? = true,
            notifyPostFollowed: Bool? = true,
            notifyPostCommented: Bool? = true,
            notifyCoachWeekly: Bool? = true,
            coachWeeklyHour: Int? = 20,
            coachWeeklyMinute: Int? = 0,
            coachWeeklyWeekday: Int? = 1,
            widgetMigrationV1Done: Bool? = false
        ) {
            self.id = id
            self.isNotificationEnabled = isNotificationEnabled
            self.wallpaperRaw = wallpaperRaw
            self.seededSocialV1 = seededSocialV1
            self.notifyFollowRequested = notifyFollowRequested
            self.notifyFollowAccepted = notifyFollowAccepted
            self.notifyFriendPosted = notifyFriendPosted
            self.notifyFriendGraduated = notifyFriendGraduated
            self.notifyPostCheered = notifyPostCheered
            self.notifyPostFollowed = notifyPostFollowed
            self.notifyPostCommented = notifyPostCommented
            self.notifyCoachWeekly = notifyCoachWeekly
            self.coachWeeklyHour = coachWeeklyHour
            self.coachWeeklyMinute = coachWeeklyMinute
            self.coachWeeklyWeekday = coachWeeklyWeekday
            self.widgetMigrationV1Done = widgetMigrationV1Done
        }
    }
}
