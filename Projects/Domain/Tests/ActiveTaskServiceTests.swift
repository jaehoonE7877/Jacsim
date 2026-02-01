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
}
