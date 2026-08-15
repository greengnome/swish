import SwiftUI

extension FocusCategory {
    var presentationColor: Color {
        SwishTheme.categoryColor(for: colorToken)
    }
}
