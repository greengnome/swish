import Foundation

enum StatsPeriod: String, CaseIterable, Identifiable, Sendable {
    case day
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    func interval(containing date: Date, calendar: Calendar) -> DateInterval {
        calendar.dateInterval(of: periodComponent, for: date)
            ?? DateInterval(start: calendar.startOfDay(for: date), duration: 86_400)
    }

    func previousInterval(containing date: Date, calendar: Calendar) -> DateInterval {
        let current = interval(containing: date, calendar: calendar)
        let previousAnchor = calendar.date(
            byAdding: periodComponent,
            value: -1,
            to: current.start
        ) ?? current.start.addingTimeInterval(-current.duration)

        return interval(containing: previousAnchor, calendar: calendar)
    }

    func bucketIntervals(containing date: Date, calendar: Calendar) -> [DateInterval] {
        let periodInterval = interval(containing: date, calendar: calendar)
        var buckets: [DateInterval] = []
        var cursor = periodInterval.start

        while cursor < periodInterval.end {
            guard let candidateEnd = calendar.date(
                byAdding: bucketComponent,
                value: 1,
                to: cursor
            ) else {
                break
            }

            let end = min(candidateEnd, periodInterval.end)
            guard end > cursor else { break }
            buckets.append(DateInterval(start: cursor, end: end))
            cursor = end
        }

        return buckets
    }

    private var periodComponent: Calendar.Component {
        switch self {
        case .day:
            .day
        case .week:
            .weekOfYear
        case .month:
            .month
        case .year:
            .year
        }
    }

    private var bucketComponent: Calendar.Component {
        switch self {
        case .day:
            .hour
        case .week, .month:
            .day
        case .year:
            .month
        }
    }
}
