import SwiftUI

struct TaskRow: View {
    let task: FocusTask
    let onToggleCompletion: () -> Void
    let onEdit: () -> Void
    let onArchive: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : SwishTheme.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                task.isCompleted
                    ? "Reopen \(task.title)"
                    : "Mark \(task.title) complete"
            )

            Button(action: onEdit) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(task.title)
                            .font(.headline)
                            .strikethrough(task.isCompleted)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)

                        Spacer(minLength: 12)

                        if task.priority == .high {
                            Image(systemName: "flag.fill")
                                .foregroundStyle(SwishTheme.accent)
                                .accessibilityLabel("High priority")
                        }
                    }

                    HStack(spacing: 8) {
                        if let category = task.category {
                            Label {
                                Text(category.name)
                            } icon: {
                                Circle()
                                    .fill(category.presentationColor)
                                    .frame(width: 8, height: 8)
                            }
                        } else {
                            Text("No category")
                        }

                        Text("•")

                        Text("\(task.completedPomodoros) / \(task.estimatedPomodoros) sessions")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    if let dueDate = task.dueDate {
                        Label {
                            Text(dueDate, style: .date)
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit \(task.title)")
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Archive", systemImage: "archivebox", role: .destructive) {
                onArchive()
            }

            Button("Edit", systemImage: "pencil") {
                onEdit()
            }
            .tint(.blue)
        }
    }
}
