import SwiftUI
import Testing
import UIKit

@testable import Swish

struct SwishThemeTests {
    @Test
    func backgroundAdaptsToInterfaceStyle() {
        let light = resolvedColor(SwishTheme.background, style: .light)
        let dark = resolvedColor(SwishTheme.background, style: .dark)

        #expect(relativeLuminance(of: light) > 0.9)
        #expect(relativeLuminance(of: dark) < 0.1)
    }

    @Test
    func surfaceAdaptsToInterfaceStyleAndRemainsAboveBackground() {
        let light = resolvedColor(SwishTheme.surface, style: .light)
        let dark = resolvedColor(SwishTheme.surface, style: .dark)
        let darkBackground = resolvedColor(SwishTheme.background, style: .dark)

        #expect(relativeLuminance(of: light) > 0.9)
        #expect(relativeLuminance(of: dark) < 0.2)
        #expect(
            relativeLuminance(of: dark) > relativeLuminance(of: darkBackground)
        )
    }

    private func resolvedColor(
        _ color: Color,
        style: UIUserInterfaceStyle
    ) -> UIColor {
        UIColor(color).resolvedColor(
            with: UITraitCollection(userInterfaceStyle: style)
        )
    }

    private func relativeLuminance(of color: UIColor) -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return 0.2126 * red + 0.7152 * green + 0.0722 * blue
    }
}
