import SwiftUI

struct HomeTimerCard: View {
    let kind: SessionKind
    let state: SessionState?
    let remainingTime: TimeInterval
    let progress: Double
    let duration: TimeInterval
    let isModeSelectionEnabled: Bool
    let onSelectMode: (SessionKind) -> Void
    let onPrimaryAction: () -> Void
    let onCancel: () -> Void
    let onSkipBreak: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Menu {
                    modeButton(.focus)
                    modeButton(.shortBreak)
                    modeButton(.longBreak)
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(SwishTheme.accent)
                            .frame(width: 9, height: 9)
                        Text(kind.title)
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(SwishTheme.accent)
                }
                .disabled(!isModeSelectionEnabled)
                .accessibilityIdentifier("home.timer.mode")

                Spacer()

                Text(TimerDisplayFormatter.durationLabel(duration))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.thinMaterial, in: Capsule())
            }

            ZStack {
                Circle()
                    .stroke(SwishTheme.accentSoft.opacity(0.45), lineWidth: 7)

                Circle()
                    .trim(from: 0, to: max(0.002, progress))
                    .stroke(
                        SwishTheme.accent,
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 7) {
                    Text(TimerDisplayFormatter.countdown(remainingTime))
                        .font(.system(size: 50, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .accessibilityIdentifier("home.timer.countdown")

                    Text(kind.timerSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 255, height: 255)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(kind.title) timer")

            HStack(spacing: 16) {
                if isActive {
                    Button(role: .destructive, action: onCancel) {
                        Image(systemName: "xmark")
                            .frame(width: 48, height: 48)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Cancel timer")
                    .accessibilityIdentifier("home.timer.cancel")
                }

                Button(action: onPrimaryAction) {
                    Label(primaryTitle, systemImage: primarySystemImage)
                        .font(.headline)
                        .frame(minWidth: isActive ? 120 : 180)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(SwishTheme.accent)
                .accessibilityIdentifier("home.timer.primary")

                if isActive && kind != .focus {
                    Button(action: onSkipBreak) {
                        Image(systemName: "forward.end.fill")
                            .frame(width: 48, height: 48)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Skip break")
                    .accessibilityIdentifier("home.timer.skip")
                }
            }
        }
        .padding(22)
        .background(
            SwishTheme.surface,
            in: RoundedRectangle(cornerRadius: SwishTheme.cardRadius)
        )
        .shadow(color: .black.opacity(0.055), radius: 18, y: 8)
    }

    private var isActive: Bool {
        state == .running || state == .paused
    }

    private var primaryTitle: String {
        switch state {
        case .running:
            "Pause"
        case .paused:
            "Resume"
        case .completed, .cancelled, .skipped, .none:
            "Start \(kind == .focus ? "focus" : "break")"
        }
    }

    private var primarySystemImage: String {
        switch state {
        case .running:
            "pause.fill"
        case .paused, .completed, .cancelled, .skipped, .none:
            "play.fill"
        }
    }

    private func modeButton(_ mode: SessionKind) -> some View {
        Button {
            onSelectMode(mode)
        } label: {
            Label(
                mode.title,
                systemImage: mode == kind ? "checkmark" : "circle"
            )
        }
    }
}
