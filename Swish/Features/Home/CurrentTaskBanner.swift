import SwiftUI

struct CurrentTaskBanner: View {
    let task: FocusTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.category?.iconName ?? "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(task.category?.presentationColor ?? SwishTheme.accent)
                .frame(width: 38, height: 38)
                .background(Color.secondary.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("Working on")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(task.title)
                    .font(.headline)
                    .lineLimit(1)
            }

            Spacer()

            Text("\(task.completedPomodoros) / \(task.estimatedPomodoros)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityLabel(
                    "\(task.completedPomodoros) of \(task.estimatedPomodoros) estimated sessions"
                )
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 14, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Working on \(task.title)")
        .accessibilityIdentifier("home.currentTask")
    }
}
