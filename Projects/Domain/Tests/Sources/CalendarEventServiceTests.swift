import Foundation
import Testing
@testable import Domain

struct CalendarEventServiceTests {
    let service = CalendarEventService()
    let calendar = Calendar.current
    
    @Test
    func testCalculateEventDatesReturnsAllDatesInRange() {
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: today,
            endDate: dayAfterTomorrow,
            stages: [],
            records: []
        )
        
        let result = service.calculateEventDates(from: [task])
        
        #expect(result.count == 3)
        #expect(result.contains(calendar.startOfDay(for: today)))
        #expect(result.contains(calendar.startOfDay(for: tomorrow)))
        #expect(result.contains(calendar.startOfDay(for: dayAfterTomorrow)))
    }
    
    @Test
    func testCalculateEventDatesWithMultipleTasks() {
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let task1 = Task(
            id: TaskID(UUID()),
            title: "Task 1",
            startDate: today,
            endDate: today,
            stages: [],
            records: []
        )
        
        let task2 = Task(
            id: TaskID(UUID()),
            title: "Task 2",
            startDate: tomorrow,
            endDate: tomorrow,
            stages: [],
            records: []
        )
        
        let result = service.calculateEventDates(from: [task1, task2])
        
        #expect(result.count == 2)
    }
    
    @Test
    func testCalculateDateColorsReturnsLowForLowSuccessRate() {
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let records = [
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: today, imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: tomorrow, imagePath: nil)
        ]
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: today,
            endDate: tomorrow,
            stages: [],
            records: records
        )
        
        let result = service.calculateDateColors(from: [task])
        
        #expect(result[calendar.startOfDay(for: today)] == .low)
    }
    
    @Test
    func testCalculateDateColorsReturnsHighForHighSuccessRate() {
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let records = [
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: today, imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: tomorrow, imagePath: nil)
        ]
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: today,
            endDate: tomorrow,
            stages: [],
            records: records
        )
        
        let result = service.calculateDateColors(from: [task])
        
        #expect(result[calendar.startOfDay(for: today)] == .high)
    }
    
    @Test
    func testCalculateDateColorsReturnsMediumForMediumSuccessRate() {
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let records = [
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: today, imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: tomorrow, imagePath: nil)
        ]
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: today,
            endDate: tomorrow,
            stages: [],
            records: records
        )
        
        let result = service.calculateDateColors(from: [task])
        
        #expect(result[calendar.startOfDay(for: today)] == .medium)
    }
}
