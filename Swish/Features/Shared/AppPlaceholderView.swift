import SwiftUI

struct AppPlaceholderView: View {
    let title: String
    let systemImage: String

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "\(title) coming next",
                systemImage: systemImage,
                description: Text("This screen will be implemented in its own reviewed batch.")
            )
            .navigationTitle(title)
            .background(SwishTheme.background)
        }
    }
}
