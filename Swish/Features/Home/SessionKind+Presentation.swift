extension SessionKind {
    var title: String {
        switch self {
        case .focus:
            "Pomodoro"
        case .shortBreak:
            "Short break"
        case .longBreak:
            "Long break"
        }
    }

    var timerSubtitle: String {
        switch self {
        case .focus:
            "Focus time"
        case .shortBreak, .longBreak:
            "Recharge"
        }
    }
}
