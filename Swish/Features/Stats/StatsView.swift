import Charts
import SwiftData
import SwiftUI

struct StatsView: View {
    @Query private var sessions: [FocusSession]
    @Query private var tasks: [FocusTask]

    @State private var selectedPeriod = StatsPeriod.week

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    periodPicker
                    focusTimeCard
                    sessionsCard
                    tasksCard
                    StatsCategoryCard(categories: snapshot.categories)
                }
                .padding(.horizontal, SwishTheme.screenPadding)
                .padding(.bottom, 24)
            }
            .background(SwishTheme.background)
            .navigationTitle("Stats")
            .accessibilityIdentifier("stats.screen")
        }
    }

    private var snapshot: StatsSnapshot {
        StatsCalculator(calendar: calendar).snapshot(
            sessions: sessions,
            tasks: tasks,
            period: selectedPeriod
        )
    }

    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(StatsPeriod.allCases) { period in
                Text(period.title).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("stats.period")
    }

    private var focusTimeCard: some View {
        StatsMetricCard(
            title: "Focus time",
            value: TimerDisplayFormatter.focusedTime(snapshot.current.focusTime),
            comparison: .make(
                comparison: snapshot.focusTimeComparison,
                period: selectedPeriod
            ),
            valueIdentifier: "stats.focusTime.value"
        ) {
            Chart(snapshot.buckets) { bucket in
                BarMark(
                    x: .value("Period", bucket.interval.start),
                    y: .value("Focus time", bucket.focusTime)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [SwishTheme.accentSoft, SwishTheme.accent],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(4)
            }
            .chartXAxis { chartXAxis }
            .chartYAxis(.hidden)
            .overlay {
                if snapshot.current.focusTime == 0 {
                    Text("No focus recorded")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .accessibilityLabel("Focus time chart")
        }
    }

    private var sessionsCard: some View {
        StatsMetricCard(
            title: "Sessions",
            value: "\(snapshot.current.completedSessions)",
            comparison: .make(
                comparison: snapshot.completedSessionsComparison,
                period: selectedPeriod
            ),
            valueIdentifier: "stats.sessions.value"
        ) {
            Chart(snapshot.buckets) { bucket in
                AreaMark(
                    x: .value("Period", bucket.interval.start),
                    y: .value("Sessions", bucket.completedSessions)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [SwishTheme.success.opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Period", bucket.interval.start),
                    y: .value("Sessions", bucket.completedSessions)
                )
                .foregroundStyle(SwishTheme.success)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                PointMark(
                    x: .value("Period", bucket.interval.start),
                    y: .value("Sessions", bucket.completedSessions)
                )
                .foregroundStyle(SwishTheme.success)
                .symbolSize(22)
            }
            .chartXAxis { chartXAxis }
            .chartYAxis(.hidden)
            .accessibilityLabel("Completed sessions chart")
        }
    }

    private var tasksCard: some View {
        StatsMetricCard(
            title: "Tasks done",
            value: "\(snapshot.current.completedTasks)",
            comparison: .make(
                comparison: snapshot.completedTasksComparison,
                period: selectedPeriod
            ),
            valueIdentifier: "stats.tasks.value"
        ) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(SwishTheme.success)

                Text("Tasks completed during this \(selectedPeriod.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @AxisContentBuilder
    private var chartXAxis: some AxisContent {
        AxisMarks(values: axisDates) { value in
            AxisValueLabel {
                if let date = value.as(Date.self) {
                    Text(selectedPeriod.bucketLabel(for: date, calendar: calendar))
                }
            }
            AxisTick().foregroundStyle(.clear)
            AxisGridLine().foregroundStyle(.clear)
        }
    }

    private var axisDates: [Date] {
        let dates = snapshot.buckets.map(\.interval.start)
        let stride: Int

        switch selectedPeriod {
        case .day:
            stride = 4
        case .week:
            stride = 1
        case .month:
            stride = 5
        case .year:
            stride = 2
        }

        return dates.enumerated().compactMap { index, date in
            index.isMultiple(of: stride) ? date : nil
        }
    }
}
