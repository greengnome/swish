import SwiftUI

struct TodaySummaryView: View {
    let summary: TodaySummary

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Today")
                    .font(.headline)
                Spacer()
                Button("View all") {}
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                metric(
                    value: "\(summary.completedSessions)",
                    title: "Sessions",
                    systemImage: "clock",
                    color: SwishTheme.accent,
                    identifier: "home.summary.sessions"
                )
                metric(
                    value: TimerDisplayFormatter.focusedTime(summary.focusTime),
                    title: "Focus time",
                    systemImage: "scope",
                    color: .orange,
                    identifier: "home.summary.focusTime"
                )
                metric(
                    value: "\(summary.completedTasks)",
                    title: "Tasks done",
                    systemImage: "checkmark.circle",
                    color: SwishTheme.success,
                    identifier: "home.summary.tasks"
                )
            }
        }
    }

    private func metric(
        value: String,
        title: String,
        systemImage: String,
        color: Color,
        identifier: String
    ) -> some View {
        VStack(spacing: 7) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .accessibilityIdentifier(identifier)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
