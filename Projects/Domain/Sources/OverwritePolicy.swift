import Foundation

public struct OverwritePolicy: Sendable, Codable, Equatable {
    public let canOverwrite: Bool
    public let reason: String
    
    public init(canOverwrite: Bool, reason: String) {
        self.canOverwrite = canOverwrite
        self.reason = reason
    }
}

public func canOverwriteRecord(
    existingRecord: DailyRecordSnapshot,
    newDate: Date
) -> OverwritePolicy {
    let calendar = Calendar.current
    
    if calendar.isDate(existingRecord.date, inSameDayAs: newDate) {
        return OverwritePolicy(
            canOverwrite: true,
            reason: "Same day record can be overwritten"
        )
    }
    
    return OverwritePolicy(
        canOverwrite: false,
        reason: "Cannot overwrite record from different day"
    )
}