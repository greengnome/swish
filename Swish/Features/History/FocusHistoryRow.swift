import SwiftUI

struct FocusHistoryRow: View {
    let entry: FocusHistoryEntry

    var body: some View {
        HStack(spacing: 14) {
            Text(entry.startedAt, format: .dateTime.hour().minute())
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 56, alignment: .leading)

            Circle()
                .fill(SwishTheme.categoryColor(for: entry.categoryColorToken))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.taskTitle ?? "Unassigned focus")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(detailText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 10)

            Text(TimerDisplayFormatter.focusedTime(entry.focusTime))
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var detailText: String {
        let outcome = entry.isCompleted ? "Completed" : "Cancelled"
        guard let categoryName = entry.categoryName else { return outcome }
        let displayedCategoryName = FocusCategoryNamePresentation.displayName(
            for: categoryName
        )
        return "\(outcome) · \(displayedCategoryName)"
    }

    private var accessibilityLabel: String {
        [
            entry.taskTitle ?? "Unassigned focus",
            detailText,
            TimerDisplayFormatter.focusedTime(entry.focusTime)
        ].joined(separator: ", ")
    }
}
