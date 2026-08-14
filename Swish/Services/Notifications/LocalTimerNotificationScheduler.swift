import Foundation
import UserNotifications

@MainActor
final class LocalTimerNotificationScheduler: TimerNotificationScheduling {
    static let identifierPrefix = "swish.timer.session"

    private let center: any UserNotificationCenterClient
    private let dateProvider: any DateProviding

    init(
        center: any UserNotificationCenterClient,
        dateProvider: any DateProviding
    ) {
        self.center = center
        self.dateProvider = dateProvider
    }

    convenience init(center: any UserNotificationCenterClient) {
        self.init(
            center: center,
            dateProvider: SystemDateProvider()
        )
    }

    func scheduleSessionEnd(id: UUID, kind: SessionKind, at date: Date) {
        let interval = date.timeIntervalSince(dateProvider.now)
        guard interval > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = notificationTitle(for: kind)
        content.body = notificationBody(for: kind)
        content.sound = .default
        content.threadIdentifier = "swish.timer"
        content.userInfo = ["sessionID": id.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: identifier(for: id),
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelSessionEnd(id: UUID) {
        center.removePendingNotificationRequests(
            withIdentifiers: [identifier(for: id)]
        )
    }

    private func identifier(for id: UUID) -> String {
        "\(Self.identifierPrefix).\(id.uuidString)"
    }

    private func notificationTitle(for kind: SessionKind) -> String {
        switch kind {
        case .focus:
            "Focus complete"
        case .shortBreak:
            "Break complete"
        case .longBreak:
            "Long break complete"
        }
    }

    private func notificationBody(for kind: SessionKind) -> String {
        switch kind {
        case .focus:
            "Great work. Time for a break."
        case .shortBreak, .longBreak:
            "Ready for another focus session?"
        }
    }
}
