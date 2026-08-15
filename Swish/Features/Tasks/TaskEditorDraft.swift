import Foundation

struct TaskEditorDraft: Equatable {
    var title: String
    var notes: String
    var categoryID: UUID?
    var estimatedPomodoros: Int
    var priority: TaskPriority
    var includesDueDate: Bool
    var dueDate: Date

    init(
        title: String = "",
        notes: String = "",
        categoryID: UUID? = nil,
        estimatedPomodoros: Int = 1,
        priority: TaskPriority = .normal,
        includesDueDate: Bool = false,
        dueDate: Date = .now
    ) {
        self.title = title
        self.notes = notes
        self.categoryID = categoryID
        self.estimatedPomodoros = max(1, estimatedPomodoros)
        self.priority = priority
        self.includesDueDate = includesDueDate
        self.dueDate = dueDate
    }

    init(task: FocusTask?) {
        self.init(
            title: task?.title ?? "",
            notes: task?.notes ?? "",
            categoryID: task?.category?.id,
            estimatedPomodoros: task?.estimatedPomodoros ?? 1,
            priority: task?.priority ?? .normal,
            includesDueDate: task?.dueDate != nil,
            dueDate: task?.dueDate ?? .now
        )
    }

    var normalizedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedNotes: String? {
        let value = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    var canSave: Bool {
        !normalizedTitle.isEmpty
    }

    func makeTask(categories: [FocusCategory], sortOrder: Int) -> FocusTask {
        FocusTask(
            title: normalizedTitle,
            notes: normalizedNotes,
            dueDate: includesDueDate ? dueDate : nil,
            category: selectedCategory(in: categories),
            priority: priority,
            estimatedPomodoros: estimatedPomodoros,
            sortOrder: sortOrder
        )
    }

    func apply(to task: FocusTask, categories: [FocusCategory]) {
        task.title = normalizedTitle
        task.notes = normalizedNotes
        task.category = selectedCategory(in: categories)
        task.estimatedPomodoros = max(1, estimatedPomodoros)
        task.priority = priority
        task.dueDate = includesDueDate ? dueDate : nil
    }

    private func selectedCategory(in categories: [FocusCategory]) -> FocusCategory? {
        categories.first { $0.id == categoryID }
    }
}
