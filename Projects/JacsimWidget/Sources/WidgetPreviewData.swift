import DSKit
import Foundation

enum WidgetPreviewData {
    static let tasks: [WidgetTask] = [
        WidgetTask(
            id: UUID(),
            title: "매일 10분 명상",
            dDay: 3,
            currentDays: 4,
            targetDays: 7,
            stageType: .seven
        ),
        WidgetTask(
            id: UUID(),
            title: "책 한 챕터",
            dDay: 10,
            currentDays: 8,
            targetDays: 14,
            stageType: .fourteen
        )
    ]

    static let streakStates: [Date: StreakState] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return Dictionary(uniqueKeysWithValues: (0..<84).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let state: StreakState = offset % 11 == 0 ? .frozen : (offset % 3 == 0 ? .active : .completed)
            return (date, state)
        })
    }()
}
