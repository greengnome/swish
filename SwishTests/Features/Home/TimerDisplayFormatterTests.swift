import Foundation
import Testing
@testable import Swish

struct TimerDisplayFormatterTests {
    @Test("Countdown rounds up partial seconds", arguments: [
        (TimeInterval(1_500), "25:00"),
        (TimeInterval(1_499.1), "25:00"),
        (TimeInterval(59), "00:59"),
        (TimeInterval(-1), "00:00"),
    ])
    func countdown(interval: TimeInterval, expected: String) {
        #expect(TimerDisplayFormatter.countdown(interval) == expected)
    }

    @Test("Focused time uses compact hour and minute units", arguments: [
        (TimeInterval(0), "0m"),
        (TimeInterval(45 * 60), "45m"),
        (TimeInterval(2 * 60 * 60), "2h"),
        (TimeInterval(2 * 60 * 60 + 15 * 60), "2h 15m"),
    ])
    func focusedTime(interval: TimeInterval, expected: String) {
        #expect(TimerDisplayFormatter.focusedTime(interval) == expected)
    }
}
