import Foundation

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
