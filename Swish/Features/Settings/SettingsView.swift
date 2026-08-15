import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationPermissionService.self) private var notificationPermissionService

    @State private var errorMessage: String?
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
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(.background)
            .navigationTitle("Settings")
            .accessibilityIdentifier("settings.screen")
        }
        .alert("Settings unavailable", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private var timerSection: some View {
        Section {
            durationPicker(
                title: "Focus",
                selection: durationBinding(\.focusDuration),
                options: TimerSettingsDraft.focusMinuteOptions,
                identifier: "settings.focusDuration"
            )
            durationPicker(
                title: "Short break",
                selection: durationBinding(\.shortBreakDuration),
                options: TimerSettingsDraft.shortBreakMinuteOptions,
                identifier: "settings.shortBreakDuration"
            )
            durationPicker(
                title: "Long break",
                selection: durationBinding(\.longBreakDuration),
                options: TimerSettingsDraft.longBreakMinuteOptions,
                identifier: "settings.longBreakDuration"
            )
        } header: {
            Text("Timer")
        } footer: {
            Text(
                "Duration changes apply to the next session, never one already in progress."
            )
        }
    }

    private var cycleSection: some View {
        Section("Cycle") {
            Picker(
                "Long break",
                selection: settingBinding(\.longBreakEvery)
            ) {
                ForEach(TimerSettingsDraft.longBreakIntervalOptions, id: \.self) { count in
                    Text("Every \(count) focus sessions").tag(count)
                }
            }
            .accessibilityIdentifier("settings.longBreakEvery")

            Toggle(
                "Auto-start breaks",
                isOn: settingBinding(\.autoStartBreaks)
            )
            .accessibilityIdentifier("settings.autoStartBreaks")
            .accessibilityValue(settings.autoStartBreaks ? "On" : "Off")

            Toggle(
                "Auto-start focus",
                isOn: settingBinding(\.autoStartFocus)
            )
            .accessibilityIdentifier("settings.autoStartFocus")
            .accessibilityValue(settings.autoStartFocus ? "On" : "Off")
        }
    }

    private var feedbackSection: some View {
        Section("Feedback") {
            Toggle("Sounds", isOn: settingBinding(\.soundEnabled))
                .accessibilityIdentifier("settings.sound")
                .accessibilityValue(settings.soundEnabled ? "On" : "Off")

            Toggle("Haptics", isOn: settingBinding(\.hapticsEnabled))
                .accessibilityIdentifier("settings.haptics")
                .accessibilityValue(settings.hapticsEnabled ? "On" : "Off")

            Toggle("Notifications", isOn: notificationsBinding)
                .accessibilityIdentifier("settings.notifications")
                .accessibilityValue(settings.notificationsEnabled ? "On" : "Off")
        }
    }

    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: appVersion)
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
                Text("\(minutes) min").tag(minutes)
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

    private func requestNotificationPermission() {
        Task { @MainActor in
            do {
                let isAuthorized = try await notificationPermissionService
                    .requestAuthorizationIfNeeded()
                if !isAuthorized {
                    settings.notificationsEnabled = false
                    persistSettings()
                    errorMessage = "Enable notifications for Swish in System Settings "
                        + "to receive timer alerts."
                }
            } catch {
                settings.notificationsEnabled = false
                persistSettings()
                errorMessage = error.localizedDescription
            }
        }
    }
}
