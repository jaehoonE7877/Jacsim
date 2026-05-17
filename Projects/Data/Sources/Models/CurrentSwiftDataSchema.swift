import Foundation
import SwiftData

public enum CurrentSwiftDataSchema: VersionedSchema {
    public static var versionIdentifier: Schema.Version {
        Schema.Version(6, 0, 0)
    }

    public static var models: [any PersistentModel.Type] {
        [
            JacsimSchemaV3.UserJacsimModel.self,
            JacsimSchemaV5.AppSettingsModel.self,
            JacsimSchemaV3.CertifiedModel.self,
            JacsimSchemaV3.StageModel.self,
            JacsimSchemaV3.UserModel.self,
            JacsimSchemaV3.FollowModel.self,
            JacsimSchemaV3.BragPostModel.self,
            BragPostVisibilityModel.self,
            JacsimSchemaV3.CheerModel.self,
            JacsimSchemaV3.CommentModel.self,
            JacsimSchemaV3.FollowChallengeModel.self
        ]
    }

    @Model
    public final class BragPostVisibilityModel {
        @Attribute(.unique) public var postId: UUID
        public var visibilityRaw: String

        public init(
            postId: UUID,
            visibilityRaw: String = "private"
        ) {
            self.postId = postId
            self.visibilityRaw = visibilityRaw
        }
    }
}
