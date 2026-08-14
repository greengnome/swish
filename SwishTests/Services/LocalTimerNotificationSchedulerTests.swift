import Foundation
import Testing
import UserNotifications
@testable import Swish

@MainActor
struct LocalTimerNotificationSchedulerTests {
    @Test("Focus notification contains the expected copy and trigger")
    func schedulesFocusCompletion() throws {
        let now = Date(timeIntervalSince1970: 50_000)
        let id = UUID(uuidString: "A3464FC7-C092-461D-A0DA-252DC8B5BBAE")!
        let center = UserNotificationCenterClientSpy()
        let scheduler = LocalTimerNotificationScheduler(
            center: center,
            dateProvider: MutableDateProvider(now: now)
        )

        scheduler.scheduleSessionEnd(
            id: id,
            kind: .focus,
            at: now.addingTimeInterval(90)
        )

        let request = try #require(center.addedRequests.first)
        let trigger = try #require(
            request.trigger as? UNTimeIntervalNotificationTrigger
        )
        #expect(request.identifier == "swish.timer.session.\(id.uuidString)")
        #expect(request.content.title == "Focus complete")
        #expect(request.content.body == "Great work. Time for a break.")
        #expect(request.content.sound != nil)
        #expect(request.content.threadIdentifier == "swish.timer")
        #expect(request.content.userInfo["sessionID"] as? String == id.uuidString)
        #expect(trigger.timeInterval == 90)
        #expect(!trigger.repeats)
    }

    @Test("Break notifications use mode-specific titles", arguments: [
        (SessionKind.shortBreak, "Break complete"),
        (SessionKind.longBreak, "Long break complete"),
    ])
    func schedulesBreakCompletion(kind: SessionKind, expectedTitle: String) throws {
        let now = Date(timeIntervalSince1970: 60_000)
        let center = UserNotificationCenterClientSpy()
        let scheduler = LocalTimerNotificationScheduler(
            center: center,
            dateProvider: MutableDateProvider(now: now)
        )

        scheduler.scheduleSessionEnd(
            id: UUID(),
            kind: kind,
            at: now.addingTimeInterval(30)
        )

        let content = try #require(center.addedRequests.first?.content)
        #expect(content.title == expectedTitle)
        #expect(content.body == "Ready for another focus session?")
    }

    @Test("A past end date is never scheduled")
    func ignoresPastDate() {
        let now = Date(timeIntervalSince1970: 70_000)
        let center = UserNotificationCenterClientSpy()
        let scheduler = LocalTimerNotificationScheduler(
            center: center,
            dateProvider: MutableDateProvider(now: now)
        )

        scheduler.scheduleSessionEnd(
            id: UUID(),
            kind: .focus,
            at: now.addingTimeInterval(-1)
        )

        #expect(center.addedRequests.isEmpty)
    }

    @Test("Cancellation removes only the matching session notification")
    func cancelsBySessionIdentifier() {
        let id = UUID(uuidString: "B7889F4E-E0DD-4EB2-8640-138FD64C42FC")!
        let center = UserNotificationCenterClientSpy()
        let scheduler = LocalTimerNotificationScheduler(
            center: center,
            dateProvider: MutableDateProvider(now: .now)
        )

        scheduler.cancelSessionEnd(id: id)

        #expect(center.removedIdentifierGroups == [[
            "swish.timer.session.\(id.uuidString)"
        ]])
    }
}
