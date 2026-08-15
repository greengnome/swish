import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationPermissionService.self) private var notificationPermissionService
    @Query private var sessions: [FocusSession]

    @State private var errorMessage: String?
    @State private var isClearHistoryConfirmationPresented = false
    @Bindable private var settings: PomodoroSettings

    init(settings: PomodoroSettings) {
        self.settings = settings
    }

    var body: some View {
        NavigationStack {
            Form {
                timerSection
                cycleSection
                feedbackSection
                appearanceSection
                dataSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(.background)
            .navigationTitle(String(localized: .appTabSettings))
            .accessibilityIdentifier("settings.screen")
        }
        .alert(
            String(
                localized: "settings.alert.unavailable",
                defaultValue: "Settings unavailable"
            ),
            isPresented: errorIsPresented
        ) {
            Button(String(localized: .commonActionOk), role: .cancel) {}
        } message: {
            Text(errorMessage ?? String(localized: .commonErrorTryAgain))
        }
        .confirmationDialog(
            String(localized: "settings.data.clear_confirmation.title", defaultValue: "Clear focus history?"),
            isPresented: $isClearHistoryConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(
                String(
                    localized: "settings.data.clear_confirmation.action",
                    defaultValue: "Clear History"
                ),
                role: .destructive
            ) {
                clearHistory()
            }
            Button(String(localized: .commonActionCancel), role: .cancel) {}
        } message: {
            Text(
                String(
                    localized: "settings.data.clear_confirmation.message",
                    defaultValue: "Recorded sessions will be permanently deleted. Your tasks and preferences will be kept."
                )
            )
        }
    }

    private var timerSection: some View {
        Section {
            durationPicker(
                title: String(localized: "settings.timer.focus", defaultValue: "Focus"),
                selection: durationBinding(\.focusDuration),
                options: TimerSettingsDraft.focusMinuteOptions,
                identifier: "settings.focusDuration"
            )
            durationPicker(
                title: String(localized: "settings.timer.short_break", defaultValue: "Short break"),
                selection: durationBinding(\.shortBreakDuration),
                options: TimerSettingsDraft.shortBreakMinuteOptions,
                identifier: "settings.shortBreakDuration"
            )
            durationPicker(
                title: String(localized: "settings.timer.long_break", defaultValue: "Long break"),
                selection: durationBinding(\.longBreakDuration),
                options: TimerSettingsDraft.longBreakMinuteOptions,
                identifier: "settings.longBreakDuration"
            )
        } header: {
            Text(String(localized: "settings.timer.section", defaultValue: "Timer"))
        } footer: {
            Text(
                String(
                    localized: "settings.timer.footer",
                    defaultValue: "Duration changes apply to the next session, never one already in progress."
                )
            )
        }
    }

    private var cycleSection: some View {
        Section(String(localized: "settings.cycle.section", defaultValue: "Cycle")) {
            Picker(
                String(localized: "settings.timer.long_break", defaultValue: "Long break"),
                selection: settingBinding(\.longBreakEvery)
            ) {
                ForEach(TimerSettingsDraft.longBreakIntervalOptions, id: \.self) { count in
                    Text(verbatim: SettingsPresentation.longBreakInterval(count)).tag(count)
                }
            }
            .accessibilityIdentifier("settings.longBreakEvery")

            Toggle(
                String(localized: "settings.cycle.auto_start_breaks", defaultValue: "Auto-start breaks"),
                isOn: settingBinding(\.autoStartBreaks)
            )
            .accessibilityIdentifier("settings.autoStartBreaks")
            .accessibilityValue(SettingsPresentation.toggleState(isOn: settings.autoStartBreaks))

            Toggle(
                String(localized: "settings.cycle.auto_start_focus", defaultValue: "Auto-start focus"),
                isOn: settingBinding(\.autoStartFocus)
            )
            .accessibilityIdentifier("settings.autoStartFocus")
            .accessibilityValue(SettingsPresentation.toggleState(isOn: settings.autoStartFocus))
        }
    }

    private var feedbackSection: some View {
        Section(String(localized: "settings.feedback.section", defaultValue: "Feedback")) {
            Toggle(
                String(
                    localized: "settings.feedback.sounds",
                    defaultValue: "Sounds"
                ),
                isOn: settingBinding(\.soundEnabled)
            )
                .accessibilityIdentifier("settings.sound")
                .accessibilityValue(SettingsPresentation.toggleState(isOn: settings.soundEnabled))

            Toggle(
                String(
                    localized: "settings.feedback.haptics",
                    defaultValue: "Haptics"
                ),
                isOn: settingBinding(\.hapticsEnabled)
            )
                .accessibilityIdentifier("settings.haptics")
                .accessibilityValue(SettingsPresentation.toggleState(isOn: settings.hapticsEnabled))

            Toggle(
                String(
                    localized: "settings.feedback.notifications",
                    defaultValue: "Notifications"
                ),
                isOn: notificationsBinding
            )
                .accessibilityIdentifier("settings.notifications")
                .accessibilityValue(SettingsPresentation.toggleState(isOn: settings.notificationsEnabled))
        }
    }

    private var aboutSection: some View {
        Section(String(localized: "settings.about.section", defaultValue: "About")) {
            LabeledContent(String(localized: "settings.about.version", defaultValue: "Version"), value: appVersion)
        }
    }

    private var appearanceSection: some View {
        Section(String(localized: "settings.appearance.section", defaultValue: "Appearance")) {
            Picker(
                String(
                    localized: "settings.appearance.theme",
                    defaultValue: "Theme"
                ),
                selection: appearanceBinding
            ) {
                ForEach(AppAppearance.allCases) { appearance in
                    Text(verbatim: appearance.title()).tag(appearance)
                }
            }
            .accessibilityIdentifier("settings.appearance")
        }
    }

    private var dataSection: some View {
        Section {
            LabeledContent(String(localized: "settings.data.recorded_sessions", defaultValue: "Recorded sessions")) {
                Text("\(recordedSessionCount)")
                    .accessibilityIdentifier("settings.historyCount")
            }

            Button(String(localized: "settings.data.clear", defaultValue: "Clear focus history"), role: .destructive) {
                isClearHistoryConfirmationPresented = true
            }
            .disabled(recordedSessionCount == 0)
            .accessibilityIdentifier("settings.clearHistory")
        } header: {
            Text(String(localized: "settings.data.section", defaultValue: "Data"))
        } footer: {
            Text(String(localized: "settings.data.footer", defaultValue: "An active or paused timer is never removed."))
        }
    }

    private func durationPicker(
        title: String,
        selection: Binding<Int>,
        options: [Int],
        identifier: String
    ) -> some View {
        Picker(title, selection: selection) {
            ForEach(options, id: \.self) { minutes in
                Text(verbatim: SettingsPresentation.minutes(minutes)).tag(minutes)
            }
        }
        .accessibilityIdentifier(identifier)
    }

    private var appVersion: String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String
        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String

        return switch (version, build) {
        case let (.some(version), .some(build)):
            "\(version) (\(build))"
        case let (.some(version), .none):
            version
        default:
            "—"
        }
    }

    private var recordedSessionCount: Int {
        sessions.count { $0.state.isTerminal }
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func persistSettings() {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }

    private func durationBinding(
        _ keyPath: ReferenceWritableKeyPath<PomodoroSettings, TimeInterval>
    ) -> Binding<Int> {
        Binding(
            get: {
                max(1, Int((settings[keyPath: keyPath] / 60).rounded()))
            },
            set: { minutes in
                settings[keyPath: keyPath] = TimeInterval(max(1, minutes) * 60)
                persistSettings()
            }
        )
    }

    private func settingBinding<Value>(
        _ keyPath: ReferenceWritableKeyPath<PomodoroSettings, Value>
    ) -> Binding<Value> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { value in
                settings[keyPath: keyPath] = value
                persistSettings()
            }
        )
    }

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { settings.notificationsEnabled },
            set: { isEnabled in
                settings.notificationsEnabled = isEnabled
                persistSettings()
                if isEnabled {
                    requestNotificationPermission()
                }
            }
        )
    }

    private var appearanceBinding: Binding<AppAppearance> {
        Binding(
            get: { settings.appearance },
            set: { appearance in
                settings.appearance = appearance
                persistSettings()
            }
        )
    }

    private func requestNotificationPermission() {
        Task { @MainActor in
            do {
                let isAuthorized = try await notificationPermissionService
                    .requestAuthorizationIfNeeded()
                if !isAuthorized {
                    settings.notificationsEnabled = false
                    persistSettings()
                    errorMessage = String(
                        localized: "settings.notifications.permission_required",
                        defaultValue: "Enable notifications for Swish in System Settings to receive timer alerts."
                    )
                }
            } catch {
                settings.notificationsEnabled = false
                persistSettings()
                errorMessage = error.localizedDescription
            }
        }
    }

    private func clearHistory() {
        do {
            try FocusHistoryCleaner.clearRecordedSessions(in: modelContext)
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}
