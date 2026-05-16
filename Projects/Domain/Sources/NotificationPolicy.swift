import Foundation

public enum NotificationSuppressionReason: String, Sendable, Codable, Equatable {
    case globalNotificationsDisabled
    case challengeNotificationsDisabled
    case missingReminderTime
    case stageNotInProgress
    case challengeNotStarted
    case stageFinished
    case completedToday
}

public struct NotificationEligibility: Sendable, Codable, Equatable {
    public let shouldSchedule: Bool
    public let suppressionReason: NotificationSuppressionReason?
    public let nextEligibleDate: Date?

    public init(
        shouldSchedule: Bool,
        suppressionReason: NotificationSuppressionReason?,
        nextEligibleDate: Date?
    ) {
        self.shouldSchedule = shouldSchedule
        self.suppressionReason = suppressionReason
        self.nextEligibleDate = nextEligibleDate
    }
}

public func evaluateNotificationEligibility(
    task: Task,
    referenceDate: Date,
    globalNotificationsEnabled: Bool
) -> NotificationEligibility {
    let calendar = Calendar.current
    let day = calendar.startOfDay(for: referenceDate)

    guard globalNotificationsEnabled else {
        return NotificationEligibility(
            shouldSchedule: false,
            suppressionReason: .globalNotificationsDisabled,
            nextEligibleDate: nil
        )
    }

    guard task.isNotificationEnabled else {
        return NotificationEligibility(
            shouldSchedule: false,
            suppressionReason: .challengeNotificationsDisabled,
            nextEligibleDate: nil
        )
    }

    guard task.alarm != nil else {
        return NotificationEligibility(
            shouldSchedule: false,
            suppressionReason: .missingReminderTime,
            nextEligibleDate: nil
        )
    }

    guard let stage = task.currentStage, stage.result == .inProgress else {
        return NotificationEligibility(
            shouldSchedule: false,
            suppressionReason: .stageNotInProgress,
            nextEligibleDate: nil
        )
    }

    let stageStart = calendar.startOfDay(for: stage.startDate)
    let stageEnd = calendar.startOfDay(for: stage.endDate)

    if day < stageStart {
        return NotificationEligibility(
            shouldSchedule: false,
            suppressionReason: .challengeNotStarted,
            nextEligibleDate: stageStart
        )
    }

    guard day <= stageEnd else {
        return NotificationEligibility(
            shouldSchedule: false,
            suppressionReason: .stageFinished,
            nextEligibleDate: nil
        )
    }

    if task.isCompleted(on: day) {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: day)
        let nextEligibleDate = tomorrow.flatMap { nextDay in
            calendar.startOfDay(for: nextDay) <= stageEnd ? calendar.startOfDay(for: nextDay) : nil
        }

        return NotificationEligibility(
            shouldSchedule: false,
            suppressionReason: .completedToday,
            nextEligibleDate: nextEligibleDate
        )
    }

    return NotificationEligibility(
        shouldSchedule: true,
        suppressionReason: nil,
        nextEligibleDate: day
    )
}
