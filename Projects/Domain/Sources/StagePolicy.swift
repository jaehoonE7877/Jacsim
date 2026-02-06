import Foundation

public func minimumSuccessDays(durationDays: Int) -> Int {
    Int(ceil(Double(durationDays) / 2.0))
}

public func evaluateStageResult(
    endDate: Date,
    durationDays: Int,
    successDays: Int,
    now: Date = .now
) -> StageResult {
    let evaluatedAt = Calendar.current.date(byAdding: .day, value: 1, to: endDate)
        ?? endDate.addingTimeInterval(86400)

    if now < evaluatedAt {
        return .inProgress
    }

    let isSuccess = successDays >= minimumSuccessDays(durationDays: durationDays)
    return isSuccess ? .success : .fail
}
