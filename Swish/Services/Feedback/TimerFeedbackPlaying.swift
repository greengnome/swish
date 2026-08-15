import UIKit

enum TimerFeedbackEvent: Equatable, Sendable {
    case started
    case paused
    case resumed
    case completed
    case cancelled
    case skipped
}

@MainActor
protocol TimerFeedbackPlaying: AnyObject {
    func play(_ event: TimerFeedbackEvent)
}

@MainActor
final class SystemTimerFeedbackPlayer: TimerFeedbackPlaying {
    func play(_ event: TimerFeedbackEvent) {
#if targetEnvironment(simulator)
        return
#else
        switch event {
        case .started, .resumed:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .paused:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .completed:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .cancelled, .skipped:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
#endif
    }
}

@MainActor
final class NoOpTimerFeedbackPlayer: TimerFeedbackPlaying {
    func play(_ event: TimerFeedbackEvent) {}
}
