import Foundation
import Testing
@testable import Domain

struct ActiveTaskServiceTests {
    let service = ActiveTaskService()
    let calendar = Calendar.current
    
    @Test
    func testFilterActiveTasksReturnsOnlyActiveTasks() {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        
        let activeTask = Task(
            id: TaskID(UUID()),
            title: "Active Task",
            startDate: yesterday,
            endDate: tomorrow,
            stages: [],
            records: []
        )
        
        let expiredTask = Task(
            id: TaskID(UUID()),
            title: "Expired Task",
            startDate: lastWeek,
            endDate: yesterday,
            stages: [],
            records: []
        )
        
        let tasks = [activeTask, expiredTask]
        let result = service.filterActiveTasks(tasks, referenceDate: today)
        
        #expect(result.count == 1)
        #expect(result.first?.title == "Active Task")
    }
    
    @Test
    func testFilterActiveTasksReturnsReversedOrder() {
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!
        
        let task1 = Task(
            id: TaskID(UUID()),
            title: "Task 1",
            startDate: today,
            endDate: dayAfterTomorrow,
            stages: [],
            records: []
        )
        
        let task2 = Task(
            id: TaskID(UUID()),
            title: "Task 2",
            startDate: today,
            endDate: tomorrow,
            stages: [],
            records: []
        )
        
        let tasks = [task1, task2]
        let result = service.filterActiveTasks(tasks, referenceDate: today)
        
        #expect(result.count == 2)
        #expect(result[0].title == "Task 2")
        #expect(result[1].title == "Task 1")
    }
    
    @Test
    func testFilterActiveTasksWithEmptyArray() {
        let result = service.filterActiveTasks([], referenceDate: Date())
        #expect(result.isEmpty)
    }
    
    @Test
    func testFilterActiveTasksIncludesTasksEndingToday() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let taskEndingToday = Task(
            id: TaskID(UUID()),
            title: "Task Ending Today",
            startDate: yesterday,
            endDate: today,
            stages: [],
            records: []
        )
        
        let result = service.filterActiveTasks([taskEndingToday], referenceDate: today)
        #expect(result.count == 1)
    }

    @Test
    func testFilterActiveTasksExcludesFutureStartTasks() {
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!

        let futureTask = Task(
            id: TaskID(UUID()),
            title: "Future Task",
            startDate: tomorrow,
            endDate: nextWeek,
            stages: [
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: StageType.seven.rawValue,
                    startDate: tomorrow,
                    endDate: nextWeek,
                    durationDays: 7,
                    successDays: 0,
                    resultRaw: StageResult.inProgress.rawValue
                )
            ],
            records: []
        )

        let result = service.filterActiveTasks([futureTask], referenceDate: today)
        #expect(result.isEmpty)
    }

    @Test
    func testFilterActiveTasksPrioritizesTodayUncertifiedTask() {
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let later = calendar.date(byAdding: .day, value: 3, to: today)!

        let completedToday = makeTask(
            title: "Completed Today",
            startDate: today,
            endDate: tomorrow,
            records: [
                DailyRecordSnapshot(
                    id: UUID(),
                    memo: "",
                    check: true,
                    date: today,
                    imagePath: nil
                )
            ]
        )
        let uncertifiedToday = makeTask(
            title: "Uncertified Today",
            startDate: today,
            endDate: later,
            records: []
        )

        let result = service.filterActiveTasks(
            [completedToday, uncertifiedToday],
            referenceDate: today
        )

        #expect(result.map(\.title) == ["Uncertified Today", "Completed Today"])
    }

    @Test
    func testFilterActiveTasksPrioritizesNearestStageEnd() {
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let later = calendar.date(byAdding: .day, value: 4, to: today)!

        let laterEndingTask = makeTask(title: "Later", startDate: today, endDate: later)
        let soonerEndingTask = makeTask(title: "Sooner", startDate: today, endDate: tomorrow)

        let result = service.filterActiveTasks(
            [laterEndingTask, soonerEndingTask],
            referenceDate: today
        )

        #expect(result.map(\.title) == ["Sooner", "Later"])
    }

    @Test
    func testFilterActiveTasksKeepsSuccessfulStageThatCanAdvance() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!

        let readyForNextStage = Task(
            id: TaskID(UUID()),
            title: "Ready For Next",
            startDate: lastWeek,
            endDate: yesterday,
            stages: [
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: StageType.seven.rawValue,
                    startDate: lastWeek,
                    endDate: yesterday,
                    durationDays: 7,
                    successDays: 4,
                    resultRaw: StageResult.success.rawValue
                )
            ],
            records: []
        )

        let result = service.filterActiveTasks([readyForNextStage], referenceDate: today)
        #expect(result.map(\.title) == ["Ready For Next"])
    }

    private func makeTask(
        title: String,
        startDate: Date,
        endDate: Date,
        records: [DailyRecordSnapshot] = []
    ) -> Task {
        Task(
            id: TaskID(UUID()),
            title: title,
            startDate: startDate,
            endDate: endDate,
            stages: [
                StageSnapshot(
                    id: UUID(),
                    stageTypeRaw: StageType.seven.rawValue,
                    startDate: startDate,
                    endDate: endDate,
                    durationDays: 7,
                    successDays: 0,
                    resultRaw: StageResult.inProgress.rawValue
                )
            ],
            records: records
        )
    }
}
