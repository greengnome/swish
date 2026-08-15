import Foundation
import Testing
@testable import Swish

struct StatsPeriodTests {
    @Test("Periods resolve current and immediately preceding calendar ranges")
    func resolvesPeriodRanges() {
        let calendar = testCalendar
        let now = date(2026, 8, 15, 12)

        let day = StatsPeriod.day.interval(containing: now, calendar: calendar)
        let previousDay = StatsPeriod.day.previousInterval(
            containing: now,
            calendar: calendar
        )

        #expect(day.start == date(2026, 8, 15))
        #expect(day.end == date(2026, 8, 16))
        #expect(previousDay.start == date(2026, 8, 14))
        #expect(previousDay.end == day.start)
    }

    @Test("Bucket counts follow the selected calendar period")
    func createsPeriodBuckets() {
        let calendar = testCalendar
        let now = date(2026, 8, 15, 12)

        #expect(StatsPeriod.day.bucketIntervals(containing: now, calendar: calendar).count == 24)
        #expect(StatsPeriod.week.bucketIntervals(containing: now, calendar: calendar).count == 7)
        #expect(StatsPeriod.month.bucketIntervals(containing: now, calendar: calendar).count == 31)
        #expect(StatsPeriod.year.bucketIntervals(containing: now, calendar: calendar).count == 12)
    }

    private var testCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2
        return calendar
    }

    private func date(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ hour: Int = 0
    ) -> Date {
        testCalendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: hour
            )
        )!
    }
}
