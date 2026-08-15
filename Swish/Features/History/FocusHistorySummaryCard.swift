import SwiftUI

struct FocusHistorySummaryCard: View {
    let day: FocusHistoryDay

    var body: some View {
        HStack {
            metric(
                value: TimerDisplayFormatter.focusedTime(day.focusTime),
                title: "Focused",
                systemImage: "scope",
                color: SwishTheme.accent,
                identifier: "history.focusTime.value"
            )

            Divider()
                .frame(height: 54)

            metric(
                value: "\(day.completedSessions)",
                title: "Sessions",
                systemImage: "clock",
                color: .orange,
                identifier: "history.sessions.value"
            )

            Divider()
                .frame(height: 54)

            metric(
                value: "\(day.completedTasks)",
                title: "Tasks",
                systemImage: "checkmark.circle",
                color: SwishTheme.success,
                identifier: "history.tasks.value"
            )
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(
            SwishTheme.surface,
            in: RoundedRectangle(cornerRadius: SwishTheme.cardRadius)
        )
        .shadow(color: .black.opacity(0.045), radius: 16, y: 7)
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
                .foregroundStyle(color)

            Text(value)
                .font(.headline)
                .monospacedDigit()
                .accessibilityIdentifier(identifier)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
