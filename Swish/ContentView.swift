import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            AppPlaceholderView(title: "Stats", systemImage: "chart.bar.fill")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            AppPlaceholderView(title: "Tasks", systemImage: "checklist")
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

            AppPlaceholderView(title: "Settings", systemImage: "gearshape.fill")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(SwishTheme.accent)
    }
}
