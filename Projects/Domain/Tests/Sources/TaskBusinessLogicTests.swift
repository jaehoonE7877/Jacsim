import Foundation
import Testing
import Domain

// Protects Task and StageSnapshot business invariants: date-range boundaries,
// completion/progress calculations, safe index guards, and raw-value fallback mapping.

@Test("Task.dayArray includes both start and end dates")
func taskDayArrayIncludesRangeBounds() {
    let start = fixedDate(year: 2026, month: 1, day: 10)
    let end = fixedDate(year: 2026, month: 1, day: 12)
    let task = makeTask(startDate: start, endDate: end)

    #expect(task.dayArray.count == 3)
    #expect(task.dayArray.first == start)
    #expect(task.dayArray.last == end)
}

@Test("Task.dayArray is empty when startDate is after endDate")
func taskDayArrayEmptyForInvalidRange() {
    let start = fixedDate(year: 2026, month: 1, day: 12)
    let end = fixedDate(year: 2026, month: 1, day: 10)
    let task = makeTask(startDate: start, endDate: end)

    #expect(task.dayArray.isEmpty)
}

@Test("Task progress and completedDays use checked records only")
func taskProgressAndCompletedDaysReflectCheckedRecords() {
    let start = fixedDate(year: 2026, month: 1, day: 1)
    let end = fixedDate(year: 2026, month: 1, day: 4)
    let task = makeTask(
        startDate: start,
        endDate: end,
        records: [
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: start, imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: fixedDate(year: 2026, month: 1, day: 2), imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: fixedDate(year: 2026, month: 1, day: 3), imagePath: nil)
        ]
    )

    #expect(task.completedDays == 2)
    #expect(abs(task.progress - 0.5) < 0.000_001)
}

@Test("Task hasRecord and isCompleted are date-based")
func taskRecordLookupUsesCalendarDaySemantics() {
    let firstDay = fixedDate(year: 2026, month: 1, day: 20)
    let secondDay = fixedDate(year: 2026, month: 1, day: 21)
    let thirdDay = fixedDate(year: 2026, month: 1, day: 22)

    let task = makeTask(
        startDate: firstDay,
        endDate: thirdDay,
        records: [
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: firstDay, imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: secondDay, imagePath: nil)
        ]
    )

    #expect(task.hasRecord(for: firstDay) == true)
    #expect(task.hasRecord(for: thirdDay) == false)
    #expect(task.isCompleted(on: firstDay) == false)
    #expect(task.isCompleted(on: secondDay) == true)
    #expect(task.isCompleted(on: thirdDay) == false)
}

@Test("Task.isToday returns false for out-of-range index")
func taskIsTodayOutOfRangeIndexReturnsFalse() {
    let start = fixedDate(year: 2026, month: 1, day: 1)
    let end = fixedDate(year: 2026, month: 1, day: 2)
    let task = makeTask(startDate: start, endDate: end)

    #expect(task.isToday(dayIndex: -1) == false)
    #expect(task.isToday(dayIndex: 999) == false)
}

@Test("StageSnapshot maps invalid raw values to safe defaults")
func stageSnapshotInvalidRawValuesFallbackToDefaults() {
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: 999,
        startDate: fixedDate(year: 2026, month: 2, day: 1),
        endDate: fixedDate(year: 2026, month: 2, day: 3),
        durationDays: 3,
        successDays: 0,
        resultRaw: "UNKNOWN"
    )

    #expect(stage.stageType == .three)
    #expect(stage.result == .inProgress)
}

@Test("StageSnapshot.stageType and result setters sync raw values")
func stageSnapshotSettersUpdateRawValues() {
    var stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.three.rawValue,
        startDate: fixedDate(year: 2026, month: 3, day: 1),
        endDate: fixedDate(year: 2026, month: 3, day: 3),
        durationDays: 3,
        successDays: 0,
        resultRaw: StageResult.inProgress.rawValue
    )

    stage.stageType = .fifteen
    stage.result = .success

    #expect(stage.stageTypeRaw == StageType.fifteen.rawValue)
    #expect(stage.resultRaw == StageResult.success.rawValue)
}

@Test("StageSnapshot.dayArray includes both start and end dates")
func stageSnapshotDayArrayIncludesRangeBounds() {
    let start = fixedDate(year: 2026, month: 4, day: 8)
    let end = fixedDate(year: 2026, month: 4, day: 10)
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.three.rawValue,
        startDate: start,
        endDate: end,
        durationDays: 3,
        successDays: 0,
        resultRaw: StageResult.inProgress.rawValue
    )

    #expect(stage.dayArray.count == 3)
    #expect(stage.dayArray.first == start)
    #expect(stage.dayArray.last == end)
}

private func makeTask(startDate: Date, endDate: Date, records: [DailyRecordSnapshot] = []) -> Task {
    Task(
        id: TaskID(UUID()),
        title: "Task",
        startDate: startDate,
        endDate: endDate,
        stages: [],
        records: records,
        isDeleted: false,
        createdAt: startDate,
        updatedAt: startDate
    )
}

private func fixedDate(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
    let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
}
