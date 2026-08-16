import Foundation
import Testing
@testable import Swish

@MainActor
struct TimerEngineRestoreTests {
    @Test("Restoring an overdue session finalizes it exactly once")
    func finalizesOverdueSession() throws {
        let start = Date(timeIntervalSince1970: 20_000)
        let session = FocusSession(
            kind: .focus,
            startedAt: start,
            plannedDuration: 60,
            endDate: start.addingTimeInterval(60)
        )
        let settings = PomodoroSettings(
            focusDuration: 60,
            autoStartBreaks: true
        )
        let harness = TimerEngineHarness(
            startDate: start.addingTimeInterval(600),
            settings: settings,
            sessions: [session]
        )

        try harness.engine.restore()

        #expect(session.state == .completed)
        #expect(session.finishedAt == start.addingTimeInterval(60))
        #expect(harness.store.sessions.count == 1)
        #expect(harness.cycle.completedFocusesInCycle == 1)

        try harness.engine.restore()
        #expect(harness.cycle.completedFocusesInCycle == 1)
    }

    @Test("Restoring a running session reschedules its notification")
    func restoresRunningSession() throws {
        let start = Date(timeIntervalSince1970: 30_000)
        let end = start.addingTimeInterval(1_500)
        let session = FocusSession(
            kind: .focus,
            startedAt: start,
            plannedDuration: 1_500,
            endDate: end
        )
        let harness = TimerEngineHarness(
            startDate: start.addingTimeInterval(100),
            sessions: [session]
        )

        try harness.engine.restore()

        #expect(harness.engine.currentSession === session)
        #expect(harness.engine.remainingTime == 1_400)
        #expect(harness.notifications.schedules == [
            .init(
                id: session.id,
                kind: .focus,
                date: end,
                soundEnabled: true
            )
        ])
    }
}
