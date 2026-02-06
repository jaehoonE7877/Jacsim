import Foundation
import Testing
@testable import Domain

struct TaskStatusServiceTests {
    let service = TaskStatusService()
    
    @Test
    func testFilterSuccessTasks() {
        let successStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: Date(),
            endDate: Date(),
            durationDays: 7,
            successDays: 5,
            resultRaw: "success"
        )
        
        let failStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: Date(),
            endDate: Date(),
            durationDays: 7,
            successDays: 1,
            resultRaw: "fail"
        )
        
        let successTask = Task(
            id: TaskID(UUID()),
            title: "Success Task",
            startDate: Date(),
            endDate: Date(),
            stages: [successStage],
            records: []
        )
        
        let failTask = Task(
            id: TaskID(UUID()),
            title: "Fail Task",
            startDate: Date(),
            endDate: Date(),
            stages: [failStage],
            records: []
        )
        
        let tasks = [successTask, failTask]
        let result = service.filterSuccessTasks(tasks)
        
        #expect(result.count == 1)
        #expect(result.first?.title == "Success Task")
    }
    
    @Test
    func testFilterFailTasks() {
        let successStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: Date(),
            endDate: Date(),
            durationDays: 7,
            successDays: 5,
            resultRaw: "success"
        )
        
        let failStage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: Date(),
            endDate: Date(),
            durationDays: 7,
            successDays: 1,
            resultRaw: "fail"
        )
        
        let successTask = Task(
            id: TaskID(UUID()),
            title: "Success Task",
            startDate: Date(),
            endDate: Date(),
            stages: [successStage],
            records: []
        )
        
        let failTask = Task(
            id: TaskID(UUID()),
            title: "Fail Task",
            startDate: Date(),
            endDate: Date(),
            stages: [failStage],
            records: []
        )
        
        let tasks = [successTask, failTask]
        let result = service.filterFailTasks(tasks)
        
        #expect(result.count == 1)
        #expect(result.first?.title == "Fail Task")
    }
    
    @Test
    func testFilterWithEmptyArray() {
        #expect(service.filterSuccessTasks([]).isEmpty)
        #expect(service.filterFailTasks([]).isEmpty)
    }
    
    @Test
    func testFilterWithNoStage() {
        let taskWithNoStage = Task(
            id: TaskID(UUID()),
            title: "No Stage Task",
            startDate: Date(),
            endDate: Date(),
            stages: [],
            records: []
        )
        
        #expect(service.filterSuccessTasks([taskWithNoStage]).isEmpty)
        #expect(service.filterFailTasks([taskWithNoStage]).isEmpty)
    }
}
