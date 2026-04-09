import Foundation
import Testing
@testable import Domain

struct ActiveTaskServiceTests {
    let service = ActiveTaskService()
    let calendar = Calendar.current
    
    @Test
    func testFilterActiveTasksReturnsOnlyStartedAndActiveTasks() {
        let today = fixedDate(year: 2026, month: 3, day: 7)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        
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

        let futureTask = Task(
            id: TaskID(UUID()),
            title: "Future Task",
            startDate: tomorrow,
            endDate: nextWeek,
            stages: [],
            records: []
        )
        
        let tasks = [activeTask, expiredTask, futureTask]
        let result = service.filterActiveTasks(tasks, referenceDate: today)
        
        #expect(result.count == 1)
        #expect(result.first?.title == "Active Task")
    }
    
    @Test
    func testFilterActiveTasksRanksPendingByClosestStageEnd() {
        let today = fixedDate(year: 2026, month: 3, day: 7)
        let soon = calendar.date(byAdding: .day, value: 1, to: today)!
        let later = calendar.date(byAdding: .day, value: 5, to: today)!
        
        let task1 = Task(
            id: TaskID(UUID()),
            title: "Task 1",
            startDate: today,
            endDate: later,
            alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 21, minute: 0),
            isNotificationEnabled: true,
            stages: [makeStage(startDate: today, endDate: later)],
            records: []
        )
        
        let task2 = Task(
            id: TaskID(UUID()),
            title: "Task 2",
            startDate: today,
            endDate: soon,
            alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 21, minute: 0),
            isNotificationEnabled: true,
            stages: [makeStage(startDate: today, endDate: soon)],
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
        let today = fixedDate(year: 2026, month: 3, day: 7)
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
    func testMakeTodayFocusSelectionReturnsAllDoneTodayWhenPendingDoesNotExist() {
        let today = fixedDate(year: 2026, month: 3, day: 7)
        let endDate = calendar.date(byAdding: .day, value: 3, to: today)!
        let doneTask = Task(
            id: TaskID(UUID()),
            title: "Done Task",
            startDate: calendar.date(byAdding: .day, value: -1, to: today)!,
            endDate: endDate,
            stages: [makeStage(startDate: calendar.date(byAdding: .day, value: -1, to: today)!, endDate: endDate)],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: today, imagePath: nil)
            ]
        )

        let selection = service.makeTodayFocusSelection(from: [doneTask], referenceDate: today)

        #expect(selection.state == .allDoneToday)
        #expect(selection.focusTask?.title == "Done Task")
        #expect(selection.pendingCount == 0)
        #expect(selection.completedTodayCount == 1)
    }

    @Test
    func testMakeTodayFocusSelectionReturnsCompletedStageReadyWhenNonFinalStageFinishedToday() {
        let today = fixedDate(year: 2026, month: 3, day: 7)
        let endDate = calendar.date(byAdding: .day, value: 3, to: today)!
        let completedStageTask = Task(
            id: TaskID(UUID()),
            title: "Stage Ready",
            startDate: calendar.date(byAdding: .day, value: -2, to: today)!,
            endDate: endDate,
            stages: [
                makeStage(
                    startDate: calendar.date(byAdding: .day, value: -2, to: today)!,
                    endDate: endDate,
                    stageType: .seven,
                    result: .success
                )
            ],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: today, imagePath: nil)
            ]
        )
        let completedTask = Task(
            id: TaskID(UUID()),
            title: "Done",
            startDate: calendar.date(byAdding: .day, value: -1, to: today)!,
            endDate: endDate,
            stages: [makeStage(startDate: calendar.date(byAdding: .day, value: -1, to: today)!, endDate: endDate)],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: today, imagePath: nil)
            ]
        )

        let selection = service.makeTodayFocusSelection(
            from: [completedTask, completedStageTask],
            referenceDate: today
        )

        #expect(selection.state == .completedStageReady)
        #expect(selection.focusTask?.title == "Stage Ready")
        #expect(selection.secondaryTasks.first?.title == "Done")
        #expect(selection.pendingCount == 0)
        #expect(selection.completedTodayCount == 2)
    }

    @Test
    func testMakeTodayFocusSelectionDoesNotTreatFinalStageSuccessAsCompletedStageReady() {
        let today = fixedDate(year: 2026, month: 3, day: 7)
        let endDate = calendar.date(byAdding: .day, value: 3, to: today)!
        let finalStageTask = Task(
            id: TaskID(UUID()),
            title: "Final Stage Done",
            startDate: calendar.date(byAdding: .day, value: -2, to: today)!,
            endDate: endDate,
            stages: [
                makeStage(
                    startDate: calendar.date(byAdding: .day, value: -2, to: today)!,
                    endDate: endDate,
                    stageType: .thirty,
                    result: .success
                )
            ],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: today, imagePath: nil)
            ]
        )

        let selection = service.makeTodayFocusSelection(from: [finalStageTask], referenceDate: today)

        #expect(selection.state == .allDoneToday)
        #expect(selection.focusTask?.title == "Final Stage Done")
        #expect(selection.pendingCount == 0)
        #expect(selection.completedTodayCount == 1)
    }

    @Test
    func testMakeTodayFocusSelectionKeepsPendingAheadOfCompletedToday() {
        let today = fixedDate(year: 2026, month: 3, day: 7)
        let endDate = calendar.date(byAdding: .day, value: 2, to: today)!
        let pendingTask = Task(
            id: TaskID(UUID()),
            title: "Pending",
            startDate: calendar.date(byAdding: .day, value: -2, to: today)!,
            endDate: endDate,
            stages: [makeStage(startDate: calendar.date(byAdding: .day, value: -2, to: today)!, endDate: endDate)],
            records: []
        )
        let completedTask = Task(
            id: TaskID(UUID()),
            title: "Completed",
            startDate: calendar.date(byAdding: .day, value: -2, to: today)!,
            endDate: endDate,
            stages: [makeStage(startDate: calendar.date(byAdding: .day, value: -2, to: today)!, endDate: endDate)],
            records: [
                DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: today, imagePath: nil)
            ]
        )

        let selection = service.makeTodayFocusSelection(
            from: [completedTask, pendingTask],
            referenceDate: today
        )

        #expect(selection.state == .pending)
        #expect(selection.focusTask?.title == "Pending")
        #expect(selection.secondaryTasks.first?.title == "Completed")
        #expect(selection.pendingCount == 1)
        #expect(selection.completedTodayCount == 1)
    }

    private func makeStage(
        startDate: Date,
        endDate: Date,
        stageType: StageType = .seven,
        result: StageResult = .inProgress
    ) -> StageSnapshot {
        StageSnapshot(
            id: UUID(),
            stageTypeRaw: stageType.rawValue,
            startDate: startDate,
            endDate: endDate,
            durationDays: stageType.durationDays,
            successDays: 0,
            resultRaw: result.rawValue
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
}
