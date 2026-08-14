import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(TimerEngine.self) private var timerEngine
    @Environment(NotificationPermissionService.self) private var notificationPermissionService
    @Environment(\.scenePhase) private var scenePhase
    @Query private var sessions: [FocusSession]
    @Query private var tasks: [FocusTask]

    @State private var selectedKind = SessionKind.focus
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 26) {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        HomeTimerCard(
                            kind: displayedKind,
                            state: timerEngine.currentSession?.state,
                            remainingTime: displayedRemainingTime(at: context.date),
                            progress: displayedProgress(at: context.date),
                            duration: displayedDuration,
                            isModeSelectionEnabled: !timerEngine.hasActiveSession,
                            onSelectMode: selectMode,
                            onPrimaryAction: primaryAction,
                            onCancel: cancelSession,
                            onSkipBreak: skipBreak
                        )
                        .onChange(of: context.date) {
                            refreshTimer()
                        }
                    }

                    TodaySummaryView(
                        summary: TodaySummary(sessions: sessions, tasks: tasks)
                    )
                }
                .padding(.horizontal, SwishTheme.screenPadding)
                .padding(.bottom, 24)
            }
            .background(SwishTheme.background)
            .navigationTitle("Swish")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "slider.horizontal.3") {}
                        .accessibilityIdentifier("home.settings")
                }
            }
        }
        .task {
            await notificationPermissionService.refreshAuthorizationStatus()
            refreshTimer()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                refreshTimer()
            }
        }
        .alert("Timer unavailable", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private var displayedKind: SessionKind {
        timerEngine.hasActiveSession
            ? timerEngine.currentSession?.kind ?? selectedKind
            : selectedKind
    }

    private var displayedDuration: TimeInterval {
        if timerEngine.hasActiveSession {
            return timerEngine.currentSession?.plannedDuration ?? 0
        }
        return timerEngine.settings.duration(for: selectedKind)
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func displayedRemainingTime(at date: Date) -> TimeInterval {
        if timerEngine.hasActiveSession {
            return timerEngine.remainingTime(at: date)
        }
        return displayedDuration
    }

    private func displayedProgress(at date: Date) -> Double {
        guard
            timerEngine.hasActiveSession,
            let session = timerEngine.currentSession,
            session.plannedDuration > 0
        else {
            return 0
        }

        return min(
            1,
            max(0, 1 - timerEngine.remainingTime(at: date) / session.plannedDuration)
        )
    }

    private func selectMode(_ kind: SessionKind) {
        selectedKind = kind
    }

    private func primaryAction() {
        do {
            switch timerEngine.currentSession?.state {
            case .running:
                try timerEngine.pause()
            case .paused:
                try timerEngine.resume()
            case .completed, .cancelled, .skipped, .none:
                startSelectedMode()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startSelectedMode() {
        Task { @MainActor in
            if timerEngine.settings.notificationsEnabled {
                _ = try? await notificationPermissionService.requestAuthorizationIfNeeded()
            }

            do {
                switch selectedKind {
                case .focus:
                    try timerEngine.startFocus()
                case .shortBreak:
                    try timerEngine.startShortBreak()
                case .longBreak:
                    try timerEngine.startLongBreak()
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func cancelSession() {
        do {
            try timerEngine.cancel()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func skipBreak() {
        do {
            try timerEngine.skipBreak()
            selectedKind = timerEngine.cycleState.nextSuggestedKind
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshTimer() {
        do {
            if try timerEngine.refresh(), !timerEngine.hasActiveSession {
                selectedKind = timerEngine.cycleState.nextSuggestedKind
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
