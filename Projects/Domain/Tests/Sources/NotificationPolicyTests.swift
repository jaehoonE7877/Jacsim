import Foundation
import Testing

import Domain

@Test("evaluateNotificationEligibility returns eligible today for pending in-progress challenge")
func notificationEligibilityAllowsPendingToday() {
    let today = fixedDate(year: 2026, month: 3, day: 7)
    let task = makeTask(
        title: "독서",
        startDate: calendar.date(byAdding: .day, value: -1, to: today)!,
        endDate: calendar.date(byAdding: .day, value: 2, to: today)!,
        alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 21, minute: 0),
        isNotificationEnabled: true,
        records: []
    )

    let eligibility = evaluateNotificationEligibility(
        task: task,
        referenceDate: today,
        globalNotificationsEnabled: true
    )

    #expect(eligibility.shouldSchedule == true)
    #expect(eligibility.suppressionReason == nil)
    #expect(eligibility.nextEligibleDate == calendar.startOfDay(for: today))
}

@Test("evaluateNotificationEligibility suppresses when global notifications are disabled")
func notificationEligibilitySuppressesWhenGlobalOff() {
    let today = fixedDate(year: 2026, month: 3, day: 7)
    let task = makeTask(
        title: "산책",
        startDate: today,
        endDate: calendar.date(byAdding: .day, value: 3, to: today)!,
        alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 8, minute: 0),
        isNotificationEnabled: true,
        records: []
    )

    let eligibility = evaluateNotificationEligibility(
        task: task,
        referenceDate: today,
        globalNotificationsEnabled: false
    )

    #expect(eligibility.shouldSchedule == false)
    #expect(eligibility.suppressionReason == .globalNotificationsDisabled)
    #expect(eligibility.nextEligibleDate == nil)
}

@Test("evaluateNotificationEligibility rolls completed-today challenge forward to tomorrow")
func notificationEligibilityAdvancesCompletedTodayToTomorrow() {
    let today = fixedDate(year: 2026, month: 3, day: 7)
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
    let task = makeTask(
        title: "작심",
        startDate: calendar.date(byAdding: .day, value: -2, to: today)!,
        endDate: calendar.date(byAdding: .day, value: 2, to: today)!,
        alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 7, minute: 30),
        isNotificationEnabled: true,
        records: [
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: today, imagePath: nil)
        ]
    )

    let eligibility = evaluateNotificationEligibility(
        task: task,
        referenceDate: today,
        globalNotificationsEnabled: true
    )

    #expect(eligibility.shouldSchedule == false)
    #expect(eligibility.suppressionReason == .completedToday)
    #expect(eligibility.nextEligibleDate == calendar.startOfDay(for: tomorrow))
}

@Test("evaluateNotificationEligibility exposes future start date as next eligible day")
func notificationEligibilityExposesFutureStartDate() {
    let today = fixedDate(year: 2026, month: 3, day: 7)
    let startDate = calendar.date(byAdding: .day, value: 2, to: today)!
    let task = makeTask(
        title: "미래 작심",
        startDate: startDate,
        endDate: calendar.date(byAdding: .day, value: 4, to: startDate)!,
        alarm: fixedDate(year: 2026, month: 3, day: 9, hour: 20, minute: 0),
        isNotificationEnabled: true,
        records: []
    )

    let eligibility = evaluateNotificationEligibility(
        task: task,
        referenceDate: today,
        globalNotificationsEnabled: true
    )

    #expect(eligibility.shouldSchedule == false)
    #expect(eligibility.suppressionReason == .challengeNotStarted)
    #expect(eligibility.nextEligibleDate == calendar.startOfDay(for: startDate))
}

private let calendar = Calendar.current

private func makeTask(
    title: String,
    startDate: Date,
    endDate: Date,
    alarm: Date?,
    isNotificationEnabled: Bool,
    records: [DailyRecordSnapshot]
) -> Task {
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.seven.rawValue,
        startDate: startDate,
        endDate: endDate,
        durationDays: 7,
        successDays: records.filter(\.check).count,
        resultRaw: StageResult.inProgress.rawValue
    )

    return Task(
        id: TaskID(UUID()),
        title: title,
        startDate: startDate,
        endDate: endDate,
        alarm: alarm,
        isNotificationEnabled: isNotificationEnabled,
        stages: [stage],
        records: records
    )
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
        timeZone: .current,
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    )
    return calendar.date(from: components)!
}
