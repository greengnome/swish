import Foundation

nonisolated enum TimerLiveActivityPresentation {
    static func pausedCountdown(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(ceil(max(0, interval)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func progress(
        remainingTime: TimeInterval,
        plannedDuration: TimeInterval
    ) -> Double {
        guard plannedDuration > 0 else { return 0 }
        let elapsedTime = plannedDuration - max(0, remainingTime)
        return min(1, max(0, elapsedTime / plannedDuration))
    }

    static func expirationDate(
        for state: TimerLiveActivityAttributes.ContentState
    ) -> Date? {
        switch state.phase {
        case let .running(endDate):
            endDate
        case .paused:
            nil
        }
    }
}
