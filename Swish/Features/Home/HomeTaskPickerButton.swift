import SwiftUI

struct HomeTaskPickerButton: View {
    let task: FocusTask?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: task?.category?.iconName ?? "checklist")
                    .font(.title3)
                    .foregroundStyle(task?.category?.presentationColor ?? SwishTheme.accent)
                    .frame(width: 38, height: 38)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("Working on")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(task?.title ?? "Choose a task (optional)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            task.map { "Working on \($0.title)" } ?? "Choose a task"
        )
        .accessibilityHint("Selects an optional task for the next focus session")
        .accessibilityIdentifier("home.taskSelector")
    }
}
