import Foundation
import Testing

import Domain

@Test("canOverwriteRecord - same day")
func canOverwriteRecordSameDay() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    
    let record = DailyRecordSnapshot(
        id: UUID(),
        memo: "",
        check: true,
        date: now,
        imagePath: nil
    )
    
    let policy = canOverwriteRecord(existingRecord: record, newDate: now)
    #expect(policy.canOverwrite == true)
}

@Test("canOverwriteRecord - different day")
func canOverwriteRecordDifferentDay() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let yesterday = now.addingTimeInterval(-86400)
    
    let record = DailyRecordSnapshot(
        id: UUID(),
        memo: "",
        check: true,
        date: yesterday,
        imagePath: nil
    )
    
    let policy = canOverwriteRecord(existingRecord: record, newDate: now)
    #expect(policy.canOverwrite == false)
}