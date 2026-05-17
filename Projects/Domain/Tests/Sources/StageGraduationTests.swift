import Domain
import Foundation
import Testing

@Test("stage graduation emits once for every stage value after last day certification")
func stageGraduationEmitsOncePerStageValue() {
    for stageType in StageType.allCases {
        let before = makeTask(stageType: stageType, lastDayCertified: false)
        let after = makeTask(stageType: stageType, lastDayCertified: true)
        let detector = StageGraduationDetector()

        let first = detector.graduationContext(before: before, after: after)
        let duplicate = detector.graduationContext(before: after, after: after)

        #expect(first?.stageTypeRaw == stageType.rawValue)
        #expect(first?.durationDays == stageType.durationDays)
        #expect(duplicate == nil)
    }
}

@Test("stage graduation emits on explicit result transition")
func stageGraduationEmitsOnResultTransition() {
    var before = makeTask(stageType: .seven, lastDayCertified: true)
    before.stages[0].result = .inProgress
    var after = before
    after.stages[0].result = .success

    let context = StageGraduationDetector().graduationContext(before: before, after: after)

    #expect(context?.stageTypeRaw == StageType.seven.rawValue)
}

private func makeTask(stageType: StageType, lastDayCertified: Bool) -> Domain.Task {
    let calendar = Calendar(identifier: .gregorian)
    let startDate = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000))
    let endDate = calendar.date(
        byAdding: .day,
        value: stageType.durationDays - 1,
        to: startDate
    )!
    let minimum = minimumSuccessDays(durationDays: stageType.durationDays)
    let records = makeRecords(
        startDate: startDate,
        durationDays: stageType.durationDays,
        checkedOffsets: checkedOffsets(durationDays: stageType.durationDays, minimum: minimum, lastDayCertified: lastDayCertified)
    )
    let stage = StageSnapshot(
        id: UUID(uuidString: "00000000-0000-4000-8000-000000000100")!,
        stageTypeRaw: stageType.rawValue,
        startDate: startDate,
        endDate: endDate,
        durationDays: stageType.durationDays,
        successDays: records.filter(\.check).count,
        resultRaw: StageResult.inProgress.rawValue
    )

    return Domain.Task(
        id: TaskID(UUID(uuidString: "00000000-0000-4000-8000-000000000200")!),
        title: "\(stageType.durationDays)일 작심",
        startDate: startDate,
        endDate: endDate,
        stages: [stage],
        records: records
    )
}

private func checkedOffsets(
    durationDays: Int,
    minimum: Int,
    lastDayCertified: Bool
) -> Set<Int> {
    var offsets = Set(0..<max(minimum - 1, 0))
    if lastDayCertified {
        offsets.insert(durationDays - 1)
    }
    return offsets
}

private func makeRecords(
    startDate: Date,
    durationDays: Int,
    checkedOffsets: Set<Int>
) -> [DailyRecordSnapshot] {
    let calendar = Calendar(identifier: .gregorian)
    return (0..<durationDays).map { offset in
        DailyRecordSnapshot(
            id: UUID(),
            memo: "",
            check: checkedOffsets.contains(offset),
            date: calendar.date(byAdding: .day, value: offset, to: startDate)!,
            imagePath: nil
        )
    }
}
