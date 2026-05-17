import Domain
import Testing

@Test("followRequested on schedules")
func notificationFollowRequestedOn() async throws {
    try await expectSchedule(.followRequested, enabled: true, expectedCount: 1)
}

@Test("followRequested off suppresses")
func notificationFollowRequestedOff() async throws {
    try await expectSchedule(.followRequested, enabled: false, expectedCount: 0)
}

@Test("followAccepted on schedules")
func notificationFollowAcceptedOn() async throws {
    try await expectSchedule(.followAccepted, enabled: true, expectedCount: 1)
}

@Test("followAccepted off suppresses")
func notificationFollowAcceptedOff() async throws {
    try await expectSchedule(.followAccepted, enabled: false, expectedCount: 0)
}

@Test("friendPosted on schedules")
func notificationFriendPostedOn() async throws {
    try await expectSchedule(.friendPosted, enabled: true, expectedCount: 1)
}

@Test("friendPosted off suppresses")
func notificationFriendPostedOff() async throws {
    try await expectSchedule(.friendPosted, enabled: false, expectedCount: 0)
}

@Test("friendGraduated on schedules")
func notificationFriendGraduatedOn() async throws {
    try await expectSchedule(.friendGraduated, enabled: true, expectedCount: 1)
}

@Test("friendGraduated off suppresses")
func notificationFriendGraduatedOff() async throws {
    try await expectSchedule(.friendGraduated, enabled: false, expectedCount: 0)
}

@Test("postCheered on schedules")
func notificationPostCheeredOn() async throws {
    try await expectSchedule(.postCheered, enabled: true, expectedCount: 1)
}

@Test("postCheered off suppresses")
func notificationPostCheeredOff() async throws {
    try await expectSchedule(.postCheered, enabled: false, expectedCount: 0)
}

@Test("postFollowed on schedules")
func notificationPostFollowedOn() async throws {
    try await expectSchedule(.postFollowed, enabled: true, expectedCount: 1)
}

@Test("postFollowed off suppresses")
func notificationPostFollowedOff() async throws {
    try await expectSchedule(.postFollowed, enabled: false, expectedCount: 0)
}

@Test("postCommented on schedules")
func notificationPostCommentedOn() async throws {
    try await expectSchedule(.postCommented, enabled: true, expectedCount: 1)
}

@Test("postCommented off suppresses")
func notificationPostCommentedOff() async throws {
    try await expectSchedule(.postCommented, enabled: false, expectedCount: 0)
}

@Test("coachWeekly on schedules")
func notificationCoachWeeklyOn() async throws {
    try await expectSchedule(.coachWeekly, enabled: true, expectedCount: 1)
}

@Test("coachWeekly off suppresses")
func notificationCoachWeeklyOff() async throws {
    try await expectSchedule(.coachWeekly, enabled: false, expectedCount: 0)
}

private func expectSchedule(
    _ trigger: SocialNotificationTrigger,
    enabled: Bool,
    expectedCount: Int
) async throws {
    var settings = SocialNotificationSettings()
    settings.setEnabled(enabled, for: trigger)
    let scheduler = RecordingSocialNotificationScheduler()

    try await NotificationTriggerService().scheduleIfEnabled(
        trigger: trigger,
        context: SocialNotificationContext(title: "title", body: "body"),
        settings: settings,
        scheduler: scheduler
    )

    #expect(await scheduler.callCount == expectedCount)
}

private actor RecordingSocialNotificationScheduler: SocialNotificationScheduling {
    private var triggers: [SocialNotificationTrigger] = []

    var callCount: Int {
        triggers.count
    }

    func scheduleSocial(
        trigger: SocialNotificationTrigger,
        context: SocialNotificationContext
    ) async throws {
        triggers.append(trigger)
    }
}
