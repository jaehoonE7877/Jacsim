import Foundation

public func nextReminderComponents(
    for task: Task,
    alarm: Date,
    now: Date = .now,
    calendar: Calendar = .current
) -> DateComponents? {
    let task = task.refreshingStageProgress(now: now, calendar: calendar)

    guard let currentStage = task.currentStage,
          currentStage.result == .inProgress else {
        return nil
    }

    let alarmComponents = calendar.dateComponents([.hour, .minute], from: alarm)
    guard let hour = alarmComponents.hour,
          let minute = alarmComponents.minute else {
        return nil
    }

    let records = task.records.isEmpty
        ? currentStage.dayArray.map {
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: $0, imagePath: nil)
        }
        : task.records

    let nextFireDate = records
        .filter { !$0.check }
        .compactMap { record -> Date? in
            let day = calendar.startOfDay(for: record.date)
            guard day >= calendar.startOfDay(for: currentStage.startDate),
                  day <= calendar.startOfDay(for: currentStage.endDate) else {
                return nil
            }

            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components)
        }
        .filter { $0 > now }
        .min()

    guard let nextFireDate else { return nil }
    return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextFireDate)
}
