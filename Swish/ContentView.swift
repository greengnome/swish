import Foundation
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab

    init() {
        let startsOnTasks = ProcessInfo.processInfo.arguments.contains(
            "--ui-testing-show-tasks"
        )
        _selectedTab = State(initialValue: startsOnTasks ? .tasks : .home)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            AppPlaceholderView(title: "Stats", systemImage: "chart.bar.fill")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(AppTab.stats)

            TasksView()
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
    }
}

private enum AppTab: Hashable {
    case home
    case stats
    case tasks
    case settings
}
