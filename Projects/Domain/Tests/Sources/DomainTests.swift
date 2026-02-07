import Testing
import Foundation
import Domain

@Test("Task imageKey는 유효한 dayIndex에서 키를 생성한다")
func taskImageKeyForValidIndex() {
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? start

    let task = Task(
        id: TaskID(UUID()),
        title: "테스트",
        startDate: start,
        endDate: end,
        stages: [],
        records: []
    )

    #expect(task.imageKey(for: 0) != nil)
    #expect(task.imageKey(for: 1) != nil)
    #expect(task.imageKey(for: 2) == nil)
}
