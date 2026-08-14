//
//  SwishApp.swift
//  Swish
//
//  Created by Kirill Gladkov on 14/08/2026.
//

import SwiftData
import SwiftUI

@main
@MainActor
struct SwishApp: App {
    private let modelContainer: ModelContainer
    @State private var timerEngine: TimerEngine

    init() {
        do {
            let dependencies = try AppDependencies.live()
            modelContainer = dependencies.modelContainer
            _timerEngine = State(initialValue: dependencies.timerEngine)
        } catch {
            fatalError("Could not create app dependencies: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(timerEngine)
        }
        .modelContainer(modelContainer)
    }
}
