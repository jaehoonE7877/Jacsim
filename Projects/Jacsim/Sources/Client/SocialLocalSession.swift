import Domain
import Foundation

public enum SocialLocalSession {
    public static let currentUserID = UserID(UUID(uuidString: "00000000-0000-4000-8000-000000000006")!)

    public static func shouldScheduleLocalNotification(
        sourceUserID: UserID? = nil,
        targetUserID: UserID?
    ) -> Bool {
        guard let targetUserID else { return true }
        return targetUserID == currentUserID && sourceUserID != currentUserID
    }
}
