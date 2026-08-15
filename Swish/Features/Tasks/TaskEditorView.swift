import SwiftData
import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let task: FocusTask?
    let categories: [FocusCategory]

    @State private var draft: TaskEditorDraft
    @State private var errorMessage: String?

    init(task: FocusTask?, categories: [FocusCategory]) {
        self.task = task
        self.categories = categories
        _draft = State(initialValue: TaskEditorDraft(task: task))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What do you want to accomplish?", text: $draft.title)
                        .accessibilityIdentifier("tasks.editor.title")
                }

                Section("Plan") {
                    Picker("Category", selection: $draft.categoryID) {
                        Text("None").tag(nil as UUID?)
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.iconName ?? "tag.fill")
                                .tag(category.id as UUID?)
                        }
                    }

                    Stepper(
                        "Focus estimate: \(draft.estimatedPomodoros) \(sessionLabel)",
                        value: $draft.estimatedPomodoros,
                        in: 1...24
                    )
                    .accessibilityIdentifier("tasks.editor.estimate")

                    Picker("Priority", selection: $draft.priority) {
                        Text("Low").tag(TaskPriority.low)
                        Text("Normal").tag(TaskPriority.normal)
                        Text("Important").tag(TaskPriority.high)
                    }

                    Toggle("Due date", isOn: $draft.includesDueDate)

                    if draft.includesDueDate {
                        DatePicker(
                            "Date",
                            selection: $draft.dueDate,
                            displayedComponents: .date
                        )
                    }
                }

                Section("Notes") {
                    TextField("Optional details", text: $draft.notes, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityIdentifier("tasks.editor.notes")
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(task == nil ? "Add" : "Save") {
                        save()
                    }
                    .disabled(!draft.canSave)
                    .accessibilityLabel(task == nil ? "Add task" : "Save task")
                    .accessibilityIdentifier("tasks.editor.save")
                }
            }
            .alert("Task could not be saved", isPresented: errorIsPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Please try again.")
            }
        }
    }

    private var sessionLabel: String {
        draft.estimatedPomodoros == 1 ? "session" : "sessions"
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func save() {
        guard draft.canSave else { return }

        if let task {
            draft.apply(to: task, categories: categories)
        } else {
            let nextSortOrder = (try? modelContext.fetchCount(FetchDescriptor<FocusTask>())) ?? 0
            modelContext.insert(
                draft.makeTask(categories: categories, sortOrder: nextSortOrder)
            )
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}
