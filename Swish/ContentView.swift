import Foundation
import SwiftUI

struct ContentView: View {
    @Environment(TimerEngine.self) private var timerEngine
    @Environment(NotificationPermissionService.self) private var notificationPermissionService

    @State private var selectedTab: AppTab
    @State private var startFocusError: String?

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let initialTab: AppTab

        if arguments.contains("--ui-testing-show-stats") {
            initialTab = .stats
        } else if arguments.contains("--ui-testing-show-tasks") {
            initialTab = .tasks
        } else {
            initialTab = .home
        }

        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.stats)

            TasksView(
                canStartFocus: !timerEngine.hasActiveSession,
                onStartFocus: startFocus
            )
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(AppTab.tasks)

            AppPlaceholderView(title: "Settings", systemImage: "gearshape.fill")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(SwishTheme.accent)
        .alert("Focus could not start", isPresented: startFocusErrorIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(startFocusError ?? "Please try again.")
        }
    }

    private var startFocusErrorIsPresented: Binding<Bool> {
        Binding(
            get: { startFocusError != nil },
            set: { if !$0 { startFocusError = nil } }
        )
    }

    private func startFocus(on task: FocusTask) {
        Task { @MainActor in
            if timerEngine.settings.notificationsEnabled {
                _ = try? await notificationPermissionService.requestAuthorizationIfNeeded()
            }

            do {
                try timerEngine.startFocus(task: task)
                selectedTab = .home
            } catch {
                startFocusError = error.localizedDescription
            }
        }
    }
}

private enum AppTab: Hashable {
    case home
    case stats
    case tasks
    case settings
}
