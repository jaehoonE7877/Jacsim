import Foundation
import SwiftData

public enum StageType: Int, CaseIterable {
    case three = 3
    case seven = 7
    case fifteen = 15
    case thirty = 30

    public var durationDays: Int {
        rawValue
    }

    public var next: StageType? {
        switch self {
        case .three:
            return .seven
        case .seven:
            return .fifteen
        case .fifteen:
            return .thirty
        case .thirty:
            return nil
        }
    }
}

public enum StageResult: String {
    case inProgress
    case success
    case fail
}

public enum ChallengeStatus: String {
    case inProgress
    case done
}

public enum ChallengeResult: String {
    case none
    case success
    case fail
}

@Model
public final class Stage {

    @Attribute(.unique) public var id: UUID

    public var stageTypeRaw: Int
    public var startDate: Date
    public var endDate: Date
    public var durationDays: Int
    public var successDays: Int
    public var resultRaw: String

    @Relationship(inverse: \UserJacsim.stages)
    public var userJacsim: UserJacsim?

    @Relationship(deleteRule: .cascade)
    public var dailyRecords: [Certified]

    public init(id: UUID = UUID(),
         stageTypeRaw: Int = StageType.three.rawValue,
         startDate: Date,
         endDate: Date,
         durationDays: Int,
         successDays: Int = 0,
         resultRaw: String = StageResult.inProgress.rawValue,
         userJacsim: UserJacsim? = nil,
         dailyRecords: [Certified] = []) {
        self.id = id
        self.stageTypeRaw = stageTypeRaw
        self.startDate = startDate
        self.endDate = endDate
        self.durationDays = durationDays
        self.successDays = successDays
        self.resultRaw = resultRaw
        self.userJacsim = userJacsim
        self.dailyRecords = dailyRecords
    }

    public var stageType: StageType {
        get { StageType(rawValue: stageTypeRaw) ?? .three }
        set { stageTypeRaw = newValue.rawValue }
    }

    public var result: StageResult {
        get { StageResult(rawValue: resultRaw) ?? .inProgress }
        set { resultRaw = newValue.rawValue }
    }
}

extension Stage: @unchecked Sendable {}
