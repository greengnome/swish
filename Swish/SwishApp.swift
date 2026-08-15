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
    private let dependencies: AppDependencies?
    @State private var onboardingStore: OnboardingStore

    init() {
        do {
            let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
            let dependencies = try AppDependencies.live(
                inMemory: isUITesting,
                notificationsEnabled: !isUITesting
            )
            self.dependencies = dependencies
            _onboardingStore = State(initialValue: OnboardingStore())
        } catch {
            dependencies = nil
            _onboardingStore = State(initialValue: OnboardingStore())
        }
    }

    var body: some Scene {
        WindowGroup {
            if let dependencies {
                Group {
                    if onboardingStore.hasCompletedOnboarding {
                        ContentView()
                    } else {
                        WelcomeView(onContinue: onboardingStore.complete)
                    }
                }
                .environment(dependencies.timerEngine)
                .environment(dependencies.notificationPermissionService)
                .preferredColorScheme(
                    dependencies.timerEngine.settings.appearance.preferredColorScheme
                )
                .modelContainer(dependencies.modelContainer)
            } else {
                StartupFailureView()
            }
        }
    }
}
