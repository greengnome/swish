import SwiftData
import SwiftUI

struct FocusHistoryView: View {
    @Query private var sessions: [FocusSession]
    @Query private var tasks: [FocusTask]

    @State private var selectedDate = Date.now

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DatePicker(
                    "History date",
                    selection: $selectedDate,
                    in: ...Date.now,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(SwishTheme.accent)
                .padding(10)
                .background(
                    SwishTheme.surface,
                    in: RoundedRectangle(cornerRadius: SwishTheme.cardRadius)
                )
                .accessibilityIdentifier("history.calendar")

                VStack(alignment: .leading, spacing: 14) {
                    Text(selectedDate, format: .dateTime.weekday(.wide).month(.wide).day())
                        .font(.title3.weight(.semibold))

                    FocusHistorySummaryCard(day: selectedDay)
                }

                sessionSection
            }
            .padding(.horizontal, SwishTheme.screenPadding)
            .padding(.bottom, 24)
        }
        .background(SwishTheme.background)
        .navigationTitle("Focus History")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("history.screen")
        .toolbar {
            if !calendar.isDateInToday(selectedDate) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Today") {
                        selectedDate = .now
                    }
                    .accessibilityIdentifier("history.today")
                }
            }
        }
    }

    private var selectedDay: FocusHistoryDay {
        FocusHistoryCalculator(calendar: calendar).day(
            containing: selectedDate,
            sessions: sessions,
            tasks: tasks
        )
    }

    @ViewBuilder
    private var sessionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sessions")
                .font(.headline)

            if selectedDay.entries.isEmpty {
                ContentUnavailableView(
                    "No focus sessions",
                    systemImage: "clock.badge.xmark",
                    description: Text("Choose another date or complete a focus session.")
                )
                .frame(maxWidth: .infinity, minHeight: 180)
                .background(
                    SwishTheme.surface,
                    in: RoundedRectangle(cornerRadius: SwishTheme.cardRadius)
                )
                .accessibilityIdentifier("history.empty")
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(selectedDay.entries.enumerated()), id: \.element.id) {
                        index,
                        entry in
                        FocusHistoryRow(entry: entry)

                        if index < selectedDay.entries.count - 1 {
                            Divider()
                                .padding(.leading, 80)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .background(
                    SwishTheme.surface,
                    in: RoundedRectangle(cornerRadius: SwishTheme.cardRadius)
                )
                .shadow(color: .black.opacity(0.045), radius: 16, y: 7)
            }
        }
    }
}
