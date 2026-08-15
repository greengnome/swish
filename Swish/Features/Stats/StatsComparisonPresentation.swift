import Foundation

enum StatsComparisonTone: Equatable, Sendable {
    case positive
    case negative
    case neutral
}

struct StatsComparisonPresentation: Equatable, Sendable {
    let text: String
    let systemImage: String
    let tone: StatsComparisonTone

    static func make(
        comparison: StatsComparison,
        period: StatsPeriod
    ) -> StatsComparisonPresentation {
        switch comparison {
        case .unavailable:
            return StatsComparisonPresentation(
                text: "No previous data",
                systemImage: "minus.circle.fill",
                tone: .neutral
            )
        case .new:
            return StatsComparisonPresentation(
                text: "New vs \(period.comparisonLabel)",
                systemImage: "sparkles",
                tone: .positive
            )
        case .unchanged:
            return StatsComparisonPresentation(
                text: "No change vs \(period.comparisonLabel)",
                systemImage: "equal.circle.fill",
                tone: .neutral
            )
        case .change(let percent):
            let roundedPercent = Int(percent.rounded())
            return StatsComparisonPresentation(
                text: "\(abs(roundedPercent))% vs \(period.comparisonLabel)",
                systemImage: roundedPercent >= 0
                    ? "arrow.up.circle.fill"
                    : "arrow.down.circle.fill",
                tone: roundedPercent >= 0 ? .positive : .negative
            )
        }
    }
}

extension StatsPeriod {
    var comparisonLabel: String {
        switch self {
        case .day:
            "yesterday"
        case .week:
            "last week"
        case .month:
            "last month"
        case .year:
            "last year"
        }
    }

    func bucketLabel(for date: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = calendar.locale ?? .current
        formatter.timeZone = calendar.timeZone

        switch self {
        case .day:
            formatter.setLocalizedDateFormatFromTemplate("j")
        case .week:
            formatter.setLocalizedDateFormatFromTemplate("EEE")
        case .month:
            formatter.setLocalizedDateFormatFromTemplate("d")
        case .year:
            formatter.setLocalizedDateFormatFromTemplate("MMM")
        }

        return formatter.string(from: date)
    }
}
