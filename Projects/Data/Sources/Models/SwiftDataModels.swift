import Foundation
import SwiftData

@Model
public final class UserJacsimModel {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var startDate: Date
    public var endDate: Date
    public var alarm: Date?
    public var isNotificationEnabled: Bool

    @Relationship(deleteRule: .cascade)
    public var memoList: [CertifiedModel]

    @Relationship(deleteRule: .cascade)
    public var stages: [StageModel]

    public init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        alarm: Date? = nil,
        isNotificationEnabled: Bool = false,
        memoList: [CertifiedModel] = [],
        stages: [StageModel] = []
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.alarm = alarm
        self.isNotificationEnabled = isNotificationEnabled || alarm != nil
        self.memoList = memoList
        self.stages = stages
    }
}

@Model
public final class AppSettingsModel {
    @Attribute(.unique) public var id: String
    public var isNotificationEnabled: Bool

    public init(id: String = "global", isNotificationEnabled: Bool = false) {
        self.id = id
        self.isNotificationEnabled = isNotificationEnabled
    }
}

@Model
public final class CertifiedModel {
    @Attribute(.unique) public var id: UUID
    public var memo: String
    public var check: Bool
    public var date: Date
    public var imagePath: String?

    @Relationship(inverse: \UserJacsimModel.memoList)
    public var userJacsim: UserJacsimModel?

    public init(
        id: UUID = UUID(),
        memo: String,
        check: Bool = false,
        date: Date = Date(),
        imagePath: String? = nil,
        userJacsim: UserJacsimModel? = nil
    ) {
        self.id = id
        self.memo = memo
        self.check = check
        self.date = date
        self.imagePath = imagePath
        self.userJacsim = userJacsim
    }
}

@Model
public final class StageModel {
    @Attribute(.unique) public var id: UUID
    public var stageTypeRaw: Int
    public var startDate: Date
    public var endDate: Date
    public var durationDays: Int
    public var successDays: Int
    public var resultRaw: String

    @Relationship(inverse: \UserJacsimModel.stages)
    public var userJacsim: UserJacsimModel?

    public init(
        id: UUID = UUID(),
        stageTypeRaw: Int = 3,
        startDate: Date,
        endDate: Date,
        durationDays: Int,
        successDays: Int = 0,
        resultRaw: String = "inProgress",
        userJacsim: UserJacsimModel? = nil
    ) {
        self.id = id
        self.stageTypeRaw = stageTypeRaw
        self.startDate = startDate
        self.endDate = endDate
        self.durationDays = durationDays
        self.successDays = successDays
        self.resultRaw = resultRaw
        self.userJacsim = userJacsim
    }
}
