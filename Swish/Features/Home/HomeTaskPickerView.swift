import SwiftUI

struct HomeTaskPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let tasks: [FocusTask]
    @Binding var selectedTaskID: UUID?

    var body: some View {
        NavigationStack {
            List {
                Button {
                    select(nil)
                } label: {
                    selectionRow(
                        title: "No task",
                        subtitle: "Keep this focus session unassigned",
                        iconName: "minus.circle",
                        color: .secondary,
                        isSelected: selectedTaskID == nil
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select no task")

                if tasks.isEmpty {
                    ContentUnavailableView(
                        "No active tasks",
                        systemImage: "checklist",
                        description: Text("Create a task from the Tasks tab first.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    Section("Active tasks") {
                        ForEach(tasks) { task in
                            Button {
                                select(task.id)
                            } label: {
                                selectionRow(
                                    title: task.title,
                                    subtitle: taskSubtitle(task),
                                    iconName: task.category?.iconName ?? "checkmark.circle",
                                    color: task.category?.presentationColor ?? SwishTheme.accent,
                                    isSelected: selectedTaskID == task.id
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Select \(task.title)")
                        }
                    }
                }
            }
            .navigationTitle("Choose Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func selectionRow(
        title: String,
        subtitle: String,
        iconName: String,
        color: Color,
        isSelected: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(SwishTheme.accent)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }

    private func taskSubtitle(_ task: FocusTask) -> String {
        let categoryName = task.category?.displayName ?? "No category"
        return "\(categoryName) • \(task.completedPomodoros) / \(task.estimatedPomodoros) sessions"
    }

    private func select(_ taskID: UUID?) {
        selectedTaskID = taskID
        dismiss()
    }
}
