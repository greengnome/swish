import Foundation
import SwiftData

@Model
final class PomodoroSettings {
    @Attribute(.unique) var id: UUID
    var focusDuration: TimeInterval
    var shortBreakDuration: TimeInterval
    var longBreakDuration: TimeInterval
    var longBreakEvery: Int
    var autoStartBreaks: Bool
    var autoStartFocus: Bool
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var notificationsEnabled: Bool
    var dailyGoal: Int?

    init(
        id: UUID = UUID(),
        focusDuration: TimeInterval = 25 * 60,
        shortBreakDuration: TimeInterval = 5 * 60,
        longBreakDuration: TimeInterval = 15 * 60,
        longBreakEvery: Int = 4,
        autoStartBreaks: Bool = false,
        autoStartFocus: Bool = false,
        soundEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        notificationsEnabled: Bool = true,
        dailyGoal: Int? = nil
    ) {
        self.id = id
        self.focusDuration = max(1, focusDuration)
        self.shortBreakDuration = max(1, shortBreakDuration)
        self.longBreakDuration = max(1, longBreakDuration)
        self.longBreakEvery = max(1, longBreakEvery)
        self.autoStartBreaks = autoStartBreaks
        self.autoStartFocus = autoStartFocus
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.notificationsEnabled = notificationsEnabled
        self.dailyGoal = dailyGoal.map { max(1, $0) }
    }

    func duration(for kind: SessionKind) -> TimeInterval {
        switch kind {
        case .focus:
            focusDuration
        case .shortBreak:
            shortBreakDuration
        case .longBreak:
            longBreakDuration
        }
    }
}
