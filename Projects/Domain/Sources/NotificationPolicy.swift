import Foundation

public struct NotificationEligibility: Sendable, Codable, Equatable {
    public let shouldSchedule: Bool
    public let reason: String
    
    public init(shouldSchedule: Bool, reason: String) {
        self.shouldSchedule = shouldSchedule
        self.reason = reason
    }
}

public func shouldScheduleNotification(
    task: Task,
    stage: StageSnapshot,
    hasRecordToday: Bool,
    notificationEnabled: Bool
) -> NotificationEligibility {
    guard notificationEnabled else {
        return NotificationEligibility(shouldSchedule: false, reason: "Notifications disabled in settings")
    }
    
    guard stage.result == .inProgress else {
        return NotificationEligibility(shouldSchedule: false, reason: "Stage not in progress")
    }
    
    let today = Date()
    guard today >= stage.startDate && today <= stage.endDate else {
        return NotificationEligibility(shouldSchedule: false, reason: "Today outside stage date range")
    }
    
    guard !hasRecordToday else {
        return NotificationEligibility(shouldSchedule: false, reason: "Record already exists for today")
    }
    
    return NotificationEligibility(shouldSchedule: true, reason: "All conditions met")
}