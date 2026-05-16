import Foundation
import Testing
@testable import Domain

struct TaskLifecycleServiceTests {
    private let service = TaskLifecycleService()
    private let calendar = Calendar.current

    @Test
    func normalizeRecalculatesStageSuccessDaysAndResultsByStageWindow() {
        let stage1Start = fixedDate(year: 2026, month: 1, day: 1)
        let stage1End = fixedDate(year: 2026, month: 1, day: 3)
        let stage2Start = fixedDate(year: 2026, month: 1, day: 4)
        let stage2End = fixedDate(year: 2026, month: 1, day: 6)

        let task = Task(
            id: TaskID(UUID()),
            title: "Lifecycle",
            startDate: stage1Start,
            endDate: stage2End,
            stages: [
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: StageType.three.rawValue,
                    startDate: stage1Start,
                    endDate: stage1End,
                    durationDays: 3,
                    successDays: 0,
                    resultRaw: StageResult.inProgress.rawValue
                ),
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: StageType.three.rawValue,
                    startDate: stage2Start,
                    endDate: stage2End,
                    durationDays: 3,
                    successDays: 99,
                    resultRaw: StageResult.success.rawValue
                )
            ],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "1", check: true, date: stage1Start, imagePath: nil),
                DailyRecordSnapshot(id: UUID(), memo: "2", check: true, date: calendar.date(byAdding: .day, value: 1, to: stage1Start)!, imagePath: nil),
                DailyRecordSnapshot(id: UUID(), memo: "3", check: false, date: stage2Start, imagePath: nil),
                DailyRecordSnapshot(id: UUID(), memo: "4", check: true, date: calendar.date(byAdding: .day, value: 1, to: stage2Start)!, imagePath: nil)
            ]
        )

        let normalized = service.normalize(task, now: fixedDate(year: 2026, month: 1, day: 8))

        #expect(normalized.stages[0].successDays == 2)
        #expect(normalized.stages[0].result == .success)
        #expect(normalized.stages[1].successDays == 1)
        #expect(normalized.stages[1].result == .fail)
    }

    @Test
    func normalizeKeepsLastStageInProgressBeforeEvaluationDate() {
        let start = fixedDate(year: 2026, month: 2, day: 1)
        let end = fixedDate(year: 2026, month: 2, day: 7)

        let task = Task(
            id: TaskID(UUID()),
            title: "In Progress",
            startDate: start,
            endDate: end,
            stages: [
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: StageType.seven.rawValue,
                    startDate: start,
                    endDate: end,
                    durationDays: 7,
                    successDays: 0,
                    resultRaw: StageResult.fail.rawValue
                )
            ],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: start, imagePath: nil),
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: calendar.date(byAdding: .day, value: 1, to: start)!, imagePath: nil),
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: calendar.date(byAdding: .day, value: 2, to: start)!, imagePath: nil),
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: calendar.date(byAdding: .day, value: 3, to: start)!, imagePath: nil)
            ]
        )

        let normalized = service.normalize(task, now: fixedDate(year: 2026, month: 2, day: 7, hour: 12))

        #expect(normalized.stages[0].successDays == 4)
        #expect(normalized.stages[0].result == .inProgress)
    }

    private func fixedDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0
    ) -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )
        return components.date ?? .distantPast
    }
}
