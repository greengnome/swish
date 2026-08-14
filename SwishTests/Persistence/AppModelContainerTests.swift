import SwiftData
import Testing
@testable import Swish

@MainActor
struct AppModelContainerTests {
    @Test("All domain models persist in the configured schema")
    func persistsDomainGraph() throws {
        let container = try AppModelContainer.make(inMemory: true)
        let context = container.mainContext
        let category = FocusCategory(name: "Study", colorToken: "purple")
        let task = FocusTask(title: "Learn Spanish", category: category)
        let session = FocusSession(
            kind: .focus,
            state: .completed,
            plannedDuration: 1_500,
            actualActiveDuration: 1_500,
            task: task
        )

        context.insert(category)
        context.insert(task)
        context.insert(session)
        context.insert(PomodoroSettings())
        context.insert(PomodoroCycleState())
        try context.save()

        #expect(try context.fetch(FetchDescriptor<FocusCategory>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<FocusTask>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<FocusSession>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<PomodoroSettings>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<PomodoroCycleState>()).count == 1)
    }
}
