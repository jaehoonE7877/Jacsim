import Foundation
import Testing

import Domain

@Test("shouldScheduleNotification - all conditions met")
func shouldScheduleNotificationAllMet() {
    let today = Date()
    let startDate = Calendar.current.date(byAdding: .day, value: -1, to: today)!
    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: 3,
        startDate: startDate,
        endDate: endDate,
        durationDays: 3,
        successDays: 0,
        resultRaw: "inProgress"
    )
    
    let task = Task(
        id: TaskID(UUID()),
        title: "Test",
        startDate: startDate,
        endDate: endDate,
        stages: [stage],
        records: []
    )
    
    let eligibility = shouldScheduleNotification(
        task: task,
        stage: stage,
        hasRecordToday: false,
        notificationEnabled: true
    )
    
    #expect(eligibility.shouldSchedule == true)
}

@Test("shouldScheduleNotification - notifications disabled")
func shouldScheduleNotificationDisabled() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: 3,
        startDate: now,
        endDate: now.addingTimeInterval(86400),
        durationDays: 3,
        successDays: 0,
        resultRaw: "inProgress"
    )
    
    let task = Task(
        id: TaskID(UUID()),
        title: "Test",
        startDate: now,
        endDate: now.addingTimeInterval(86400),
        stages: [stage],
        records: []
    )
    
    let eligibility = shouldScheduleNotification(
        task: task,
        stage: stage,
        hasRecordToday: false,
        notificationEnabled: false
    )
    
    #expect(eligibility.shouldSchedule == false)
}

@Test("shouldScheduleNotification - already has record")
func shouldScheduleNotificationHasRecord() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: 3,
        startDate: now,
        endDate: now.addingTimeInterval(86400),
        durationDays: 3,
        successDays: 0,
        resultRaw: "inProgress"
    )
    
    let task = Task(
        id: TaskID(UUID()),
        title: "Test",
        startDate: now,
        endDate: now.addingTimeInterval(86400),
        stages: [stage],
        records: []
    )
    
    let eligibility = shouldScheduleNotification(
        task: task,
        stage: stage,
        hasRecordToday: true,
        notificationEnabled: true
    )
    
    #expect(eligibility.shouldSchedule == false)
}