import Charts
import SwiftUI

struct StatsCategoryCard: View {
    let categories: [CategoryFocusStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Top categories")
                .font(.headline)

            if categories.isEmpty {
                ContentUnavailableView(
                    "No focus time yet",
                    systemImage: "chart.pie",
                    description: Text("Completed and cancelled focus sessions appear here.")
                )
                .frame(maxWidth: .infinity, minHeight: 150)
                .accessibilityIdentifier("stats.categories.empty")
            } else {
                HStack(spacing: 22) {
                    Chart(categories) { category in
                        SectorMark(
                            angle: .value("Focus time", category.focusTime),
                            innerRadius: .ratio(0.64),
                            angularInset: 1.5
                        )
                        .foregroundStyle(categoryColor(category.colorToken))
                        .cornerRadius(4)
                    }
                    .frame(width: 128, height: 128)
                    .chartLegend(.hidden)
                    .accessibilityLabel("Focus time by category")

                    VStack(alignment: .leading, spacing: 13) {
                        ForEach(categories.prefix(4)) { category in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(categoryColor(category.colorToken))
                                    .frame(width: 9, height: 9)

                                Text(category.name)
                                    .font(.subheadline)
                                    .lineLimit(1)

                                Spacer(minLength: 8)

                                Text(category.fraction, format: .percent.precision(.fractionLength(0)))
                                    .font(.subheadline.weight(.semibold))
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(
            SwishTheme.surface,
            in: RoundedRectangle(cornerRadius: SwishTheme.cardRadius)
        )
        .shadow(color: .black.opacity(0.045), radius: 16, y: 7)
    }

    private func categoryColor(_ token: String) -> Color {
        switch token.lowercased() {
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
