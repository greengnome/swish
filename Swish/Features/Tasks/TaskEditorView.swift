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
                Section {
                    TextField(
                        String(localized: .tasksEditorTitlePlaceholder),
                        text: $draft.title
                    )
                        .accessibilityIdentifier("tasks.editor.title")
                } header: {
                    Text(.tasksEditorTaskSection)
                }

                Section {
                    Picker(
                        String(localized: .tasksEditorCategory),
                        selection: $draft.categoryID
                    ) {
                        Text(.commonCategoryNone).tag(nil as UUID?)
                        ForEach(categories) { category in
                            Label {
                                Text(verbatim: category.displayName)
                            } icon: {
                                Image(systemName: category.iconName ?? "tag.fill")
                            }
                                .tag(category.id as UUID?)
                        }
                    }

                    Stepper(
                        focusEstimateLabel,
                        value: $draft.estimatedPomodoros,
                        in: 1...24
                    )
                    .accessibilityIdentifier("tasks.editor.estimate")

                    Picker(
                        String(localized: .tasksEditorPriority),
                        selection: $draft.priority
                    ) {
                        Text(.tasksPriorityLow).tag(TaskPriority.low)
                        Text(.tasksPriorityNormal).tag(TaskPriority.normal)
                        Text(.tasksPriorityHigh).tag(TaskPriority.high)
                    }

                    Toggle(
                        String(localized: .tasksEditorDueDate),
                        isOn: $draft.includesDueDate
                    )

                    if draft.includesDueDate {
                        DatePicker(
                            String(localized: .tasksEditorDate),
                            selection: $draft.dueDate,
                            displayedComponents: .date
                        )
                    }
                } header: {
                    Text(.tasksEditorPlanSection)
                }

                Section {
                    TextField(
                        String(localized: .tasksEditorNotesPlaceholder),
                        text: $draft.notes,
                        axis: .vertical
                    )
                        .lineLimit(3...6)
                        .accessibilityIdentifier("tasks.editor.notes")
                } header: {
                    Text(.tasksEditorNotesSection)
                }
            }
            .navigationTitle(
                Text(task == nil ? .tasksEditorNewTitle : .tasksEditorEditTitle)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(.commonActionCancel)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Text(task == nil ? .tasksActionAddShort : .tasksActionSave)
                    }
                    .disabled(!draft.canSave)
                    .accessibilityLabel(
                        Text(
                            task == nil
                                ? .tasksActionAdd
                                : .tasksActionSaveAccessibility
                        )
                    )
                    .accessibilityIdentifier("tasks.editor.save")
                }
            }
            .alert(
                String(localized: .tasksAlertSaveFailed),
                isPresented: errorIsPresented
            ) {
                Button(String(localized: .commonActionOk), role: .cancel) {}
            } message: {
                Text(errorMessage ?? String(localized: .commonErrorTryAgain))
            }
        }
    }

    private var focusEstimateLabel: String {
        let count = TimerDisplayFormatter.sessionCount(draft.estimatedPomodoros)
        return String(
            localized: "tasks.editor.focus_estimate",
            defaultValue: "Focus estimate: \(count)"
        )
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
