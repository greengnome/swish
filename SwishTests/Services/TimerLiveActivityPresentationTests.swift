import Foundation
import Testing
@testable import Swish

struct TimerLiveActivityPresentationTests {
    @Test("Paused countdown rounds up and clamps invalid values", arguments: [
        (TimeInterval(625), "10:25"),
        (TimeInterval(59.1), "01:00"),
        (TimeInterval(-1), "00:00"),
    ])
    func pausedCountdown(interval: TimeInterval, expected: String) {
        #expect(TimerLiveActivityPresentation.pausedCountdown(interval) == expected)
    }

    @Test("Progress is normalized to the complete unit interval", arguments: [
        (TimeInterval(1_500), TimeInterval(1_500), 0.0),
        (TimeInterval(750), TimeInterval(1_500), 0.5),
        (TimeInterval(0), TimeInterval(1_500), 1.0),
        (TimeInterval(-10), TimeInterval(1_500), 1.0),
        (TimeInterval(100), TimeInterval(0), 0.0),
    ])
    func progress(
        remainingTime: TimeInterval,
        plannedDuration: TimeInterval,
        expected: Double
    ) {
        #expect(
            TimerLiveActivityPresentation.progress(
                remainingTime: remainingTime,
                plannedDuration: plannedDuration
            ) == expected
        )
    }
}
