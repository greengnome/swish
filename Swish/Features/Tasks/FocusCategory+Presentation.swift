import SwiftUI

extension FocusCategory {
    var presentationColor: Color {
        switch colorToken.lowercased() {
        case "coral", "orange":
            SwishTheme.accent
        case "green":
            .green
        case "blue":
            .blue
        case "purple":
            .purple
        default:
            .secondary
        }
    }
}
