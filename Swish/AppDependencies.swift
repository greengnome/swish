import SwiftData

@MainActor
struct AppDependencies {
    let modelContainer: ModelContainer
    let timerEngine: TimerEngine

    static func live() throws -> AppDependencies {
        let container = try AppModelContainer.make()
        let context = container.mainContext
        let settings = try fetchOrInsert(PomodoroSettings.self, in: context) {
            PomodoroSettings()
        }
        let cycleState = try fetchOrInsert(PomodoroCycleState.self, in: context) {
            PomodoroCycleState()
        }
        let engine = TimerEngine(
            store: SwiftDataTimerSessionStore(context: context),
            settings: settings,
            cycleState: cycleState
        )
        try engine.restore()

        return AppDependencies(
            modelContainer: container,
            timerEngine: engine
        )
    }

    private static func fetchOrInsert<Model: PersistentModel>(
        _ type: Model.Type,
        in context: ModelContext,
        create: () -> Model
    ) throws -> Model {
        var descriptor = FetchDescriptor<Model>()
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let model = create()
        context.insert(model)
        try context.save()
        return model
    }
}
