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
    @State private var notificationPermissionService: NotificationPermissionService
    @State private var onboardingStore: OnboardingStore

    init() {
        do {
            let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
            let dependencies = try AppDependencies.live(
                inMemory: isUITesting,
                notificationsEnabled: !isUITesting
            )
            modelContainer = dependencies.modelContainer
            _timerEngine = State(initialValue: dependencies.timerEngine)
            _notificationPermissionService = State(
                initialValue: dependencies.notificationPermissionService
            )
            _onboardingStore = State(initialValue: OnboardingStore())
        } catch {
            fatalError("Could not create app dependencies: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingStore.hasCompletedOnboarding {
                    ContentView()
                } else {
                    WelcomeView(onContinue: onboardingStore.complete)
                }
            }
                .environment(timerEngine)
                .environment(notificationPermissionService)
                .preferredColorScheme(
                    timerEngine.settings.appearance.preferredColorScheme
                )
        }
        .modelContainer(modelContainer)
    }
}
