import Foundation

public enum StageType: Int, CaseIterable, Sendable {
    case three = 3
    case seven = 7
    case fourteen = 14
    case fifteen = 15
    case twentyOne = 21
    case thirty = 30
    case fortyFive = 45
    case sixty = 60
    case ninety = 90
    case oneEighty = 180

    public var durationDays: Int {
        rawValue
    }

    public var next: StageType? {
        switch self {
        case .three:
            return .seven
        case .seven:
            return .fourteen
        case .fourteen:
            return .twentyOne
        case .fifteen:
            return .thirty
        case .twentyOne:
            return .thirty
        case .thirty:
            return .fortyFive
        case .fortyFive:
            return .sixty
        case .sixty:
            return .ninety
        case .ninety:
            return .oneEighty
        case .oneEighty:
            return nil
        }
    }
}

public enum StageResult: String, Sendable, Codable, Equatable {
    case inProgress
    case success
    case fail
}

public enum ChallengeStatus: String, Sendable {
    case inProgress
    case done
}

public enum ChallengeResult: String, Sendable {
    case none
    case success
    case fail
}
