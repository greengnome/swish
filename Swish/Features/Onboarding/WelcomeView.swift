import SwiftUI

struct WelcomeView: View {
    @State private var selectedPage = 0

    let onContinue: () -> Void

    private let pages = OnboardingPage.allCases

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPage) {
                ForEach(Array(pages.enumerated()), id: \.element) { index, page in
                    OnboardingPageView(
                        page: page,
                        isActive: selectedPage == index
                    )
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageIndicator
                .padding(.top, 8)

            Button(action: advance) {
                Text(
                    selectedPage == pages.indices.last
                        ? .onboardingActionFinish
                        : .onboardingActionContinue
                )
                .id(selectedPage == pages.indices.last)
                .contentTransition(.opacity)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                LinearGradient(
                    colors: [SwishTheme.accent, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .padding(.horizontal, SwishTheme.screenPadding)
            .padding(.top, 30)
            .animation(.easeInOut(duration: 0.2), value: selectedPage)
            .accessibilityIdentifier("onboarding.continue")
        }
        .padding(.bottom, 28)
        .background(SwishTheme.background)
    }

    private var pageIndicator: some View {
        HStack(spacing: 12) {
            ForEach(pages.indices, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedPage = index
                    }
                } label: {
                    Capsule()
                        .fill(
                            index == selectedPage
                                ? SwishTheme.accent
                                : .secondary.opacity(0.18)
                        )
                        .frame(
                            width: index == selectedPage ? 22 : 8,
                            height: 8
                        )
                        .animation(
                            .spring(response: 0.35, dampingFraction: 0.8),
                            value: selectedPage
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    Text(
                        LocalizedStringResource(
                            "onboarding.accessibility.page",
                            defaultValue: "Onboarding page \(index + 1)",
                            comment: "VoiceOver label for an onboarding page indicator."
                        )
                    )
                )
                .accessibilityValue(
                    Text(
                        index == selectedPage
                            ? .onboardingPageSelected
                            : .onboardingPageNotSelected
                    )
                )
                .accessibilityIdentifier("onboarding.page.\(index + 1)")
            }
        }
    }

    private func advance() {
        guard selectedPage < pages.count - 1 else {
            onContinue()
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            selectedPage += 1
        }
    }
}

private enum OnboardingPage: String, CaseIterable {
    case focus
    case tasks
    case insights

    var title: LocalizedStringResource {
        switch self {
        case .focus:
            .onboardingFocusTitle
        case .tasks:
            .onboardingTasksTitle
        case .insights:
            .onboardingInsightsTitle
        }
    }

    var message: LocalizedStringResource {
        switch self {
        case .focus:
            .onboardingFocusMessage
        case .tasks:
            .onboardingTasksMessage
        case .insights:
            .onboardingInsightsMessage
        }
    }
}

private struct OnboardingPageView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isPresented = false

    let page: OnboardingPage
    let isActive: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 36)

                OnboardingArtwork(
                    page: page,
                    isPresented: isPresented,
                    reduceMotion: reduceMotion
                )
                    .frame(width: 270, height: 270)
                    .accessibilityHidden(true)

                VStack(spacing: 12) {
                    Text(page.title)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("onboarding.\(page.rawValue).title")

                    Text(page.message)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 28)
                .opacity(isPresented ? 1 : 0)
                .offset(
                    y: reduceMotion || isPresented ? 0 : 18
                )
                .animation(
                    reduceMotion
                        ? nil
                        : .easeOut(duration: 0.45).delay(0.34),
                    value: isPresented
                )

                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .task(id: animationPolicy) {
            await updatePresentation()
        }
    }

    private var animationPolicy: OnboardingAnimationPolicy {
        OnboardingAnimationPolicy(
            isActive: isActive,
            reduceMotion: reduceMotion
        )
    }

    @MainActor
    private func updatePresentation() async {
        var resetTransaction = Transaction()
        resetTransaction.disablesAnimations = true
        withTransaction(resetTransaction) {
            isPresented = animationPolicy.presentsImmediately
        }

        guard animationPolicy.runsEntranceAnimation else { return }

        await Task.yield()
        guard !Task.isCancelled else { return }
        isPresented = true
    }
}

nonisolated struct OnboardingAnimationPolicy: Equatable, Sendable {
    let isActive: Bool
    let reduceMotion: Bool

    var presentsImmediately: Bool {
        isActive && reduceMotion
    }

    var runsEntranceAnimation: Bool {
        isActive && !reduceMotion
    }
}

private struct OnboardingArtwork: View {
    let page: OnboardingPage
    let isPresented: Bool
    let reduceMotion: Bool

    var body: some View {
        switch page {
        case .focus:
            focusArtwork
        case .tasks:
            tasksArtwork
        case .insights:
            insightsArtwork
        }
    }

    private var focusArtwork: some View {
        OrbitalFocusArtwork(
            isPresented: isPresented,
            reduceMotion: reduceMotion
        )
    }

    private var tasksArtwork: some View {
        VStack(spacing: 14) {
            taskCard(
                title: .onboardingTasksProjectRoadmap,
                progress: Text(verbatim: "2 / 4"),
                color: SwishTheme.accent,
                index: 0
            )

            taskCard(
                title: .onboardingTasksReadPages,
                progress: Text(.onboardingTasksDone),
                color: SwishTheme.success,
                index: 1
            )

            taskCard(
                title: .onboardingTasksLearnSpanish,
                progress: Text(verbatim: "1 / 3"),
                color: .purple,
                index: 2
            )
        }
        .padding(20)
    }

    private var insightsArtwork: some View {
        VStack(spacing: 22) {
            HStack(alignment: .bottom, spacing: 13) {
                bar(height: 48, color: SwishTheme.accentSoft, index: 0)
                bar(height: 72, color: SwishTheme.accentSoft, index: 1)
                bar(height: 102, color: SwishTheme.accent, index: 2)
                bar(height: 64, color: SwishTheme.accentSoft, index: 3)
                bar(height: 88, color: SwishTheme.accentSoft, index: 4)
            }
            .frame(height: 112, alignment: .bottom)

            HStack(spacing: 16) {
                insightMetric(
                    value: Text(.onboardingInsightsFocusValue),
                    label: .onboardingInsightsFocusLabel
                )
                insightMetric(
                    value: Text(verbatim: "5"),
                    label: .onboardingInsightsSessionsLabel
                )
            }
            .opacity(isPresented ? 1 : 0)
            .offset(y: reduceMotion || isPresented ? 0 : 10)
            .animation(
                reduceMotion
                    ? nil
                    : .easeOut(duration: 0.35).delay(0.42),
                value: isPresented
            )
        }
        .padding(24)
        .background(SwishTheme.surface, in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.06), radius: 20, y: 10)
        .padding(10)
        .scaleEffect(reduceMotion || isPresented ? 1 : 0.94)
        .opacity(isPresented ? 1 : 0)
        .animation(
            reduceMotion
                ? nil
                : .spring(response: 0.48, dampingFraction: 0.82),
            value: isPresented
        )
    }

    private func taskCard(
        title: LocalizedStringResource,
        progress: Text,
        color: Color,
        index: Int
    ) -> some View {
        let restingOffset: CGFloat = switch index {
        case 0: -8.0
        case 1: 10.0
        default: -4.0
        }
        let entranceOffset: CGFloat = index.isMultiple(of: 2) ? -52.0 : 52.0

        return HStack(spacing: 13) {
            Circle()
                .trim(from: 0, to: isPresented ? 1 : 0)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 25, height: 25)
                .rotationEffect(.degrees(-90))

            Text(title)
                .font(.headline)

            Spacer()

            progress
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(17)
        .background(SwishTheme.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 5)
        }
        .shadow(color: .black.opacity(0.05), radius: 12, y: 6)
        .offset(
            x: restingOffset
                + (reduceMotion || isPresented ? 0 : entranceOffset)
        )
        .opacity(isPresented ? 1 : 0)
        .animation(
            reduceMotion
                ? nil
                : .spring(response: 0.5, dampingFraction: 0.82)
                    .delay(Double(index) * 0.09),
            value: isPresented
        )
    }

    private func bar(
        height: CGFloat,
        color: Color,
        index: Int
    ) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(color)
            .frame(
                width: 25,
                height: reduceMotion || isPresented ? height : 6
            )
            .animation(
                reduceMotion
                    ? nil
                    : .spring(response: 0.52, dampingFraction: 0.8)
                        .delay(0.1 + Double(index) * 0.06),
                value: isPresented
            )
    }

    private func insightMetric(
        value: Text,
        label: LocalizedStringResource
    ) -> some View {
        VStack(spacing: 4) {
            value
                .font(.title3.weight(.bold))
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

nonisolated struct OnboardingOrbitalMotionPolicy: Equatable, Sendable {
    let isPresented: Bool
    let reduceMotion: Bool

    var runsContinuously: Bool {
        isPresented && !reduceMotion
    }

    func rotation(
        at time: TimeInterval,
        period: TimeInterval,
        direction: Double = 1,
        offset: Double = 0
    ) -> Double {
        guard runsContinuously else { return offset }

        let progress = time.truncatingRemainder(dividingBy: period) / period
        return offset + progress * 360 * direction
    }

    func endpointRotation(
        baseRotation: Double,
        visibleFraction: Double
    ) -> Double {
        baseRotation + visibleFraction * 360
    }

    func trailRotation(
        nodeRotation: Double,
        trailIndex: Int,
        direction: Double
    ) -> Double {
        nodeRotation - Double(trailIndex) * 4.5 * direction
    }
}

private struct OrbitalFocusArtwork: View {
    let isPresented: Bool
    let reduceMotion: Bool

    private var motionPolicy: OnboardingOrbitalMotionPolicy {
        OnboardingOrbitalMotionPolicy(
            isPresented: isPresented,
            reduceMotion: reduceMotion
        )
    }

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0,
                paused: !motionPolicy.runsContinuously
            )
        ) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let outerTrim = 0.38
            let middleTrim = 0.29
            let innerTrim = 0.34
            let outerRotation = motionPolicy.rotation(
                at: time,
                period: 14,
                offset: 18
            )
            let middleRotation = motionPolicy.rotation(
                at: time,
                period: 11,
                direction: -1,
                offset: -62
            )
            let innerRotation = motionPolicy.rotation(
                at: time,
                period: 8,
                offset: 132
            )

            ZStack {
                orbitalRing(
                    diameter: 232,
                    trim: outerTrim,
                    lineWidth: 4,
                    rotation: outerRotation,
                    color: .orange
                )
                orbitingNode(
                    radius: 116,
                    rotation: motionPolicy.endpointRotation(
                        baseRotation: outerRotation,
                        visibleFraction: outerTrim
                    ),
                    size: 9,
                    direction: 1
                )

                orbitalRing(
                    diameter: 184,
                    trim: middleTrim,
                    lineWidth: 3,
                    rotation: middleRotation,
                    color: SwishTheme.accentSoft
                )
                orbitingNode(
                    radius: 92,
                    rotation: motionPolicy.endpointRotation(
                        baseRotation: middleRotation,
                        visibleFraction: middleTrim
                    ),
                    size: 8,
                    direction: -1
                )

                orbitalRing(
                    diameter: 140,
                    trim: innerTrim,
                    lineWidth: 3,
                    rotation: innerRotation,
                    color: SwishTheme.accent
                )
                orbitingNode(
                    radius: 70,
                    rotation: motionPolicy.endpointRotation(
                        baseRotation: innerRotation,
                        visibleFraction: innerTrim
                    ),
                    size: 7,
                    direction: 1
                )

                precisionTicks
                focusCore(time: time)
            }
            .frame(width: 260, height: 260)
        }
    }

    private func orbitalRing(
        diameter: CGFloat,
        trim: Double,
        lineWidth: CGFloat,
        rotation: Double,
        color: Color
    ) -> some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.12), lineWidth: 1)

            Circle()
                .trim(from: 0, to: isPresented ? CGFloat(trim) : 0.001)
                .stroke(
                    AngularGradient(
                        colors: [
                            color.opacity(0.18),
                            color,
                            color.opacity(0.72)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: diameter, height: diameter)
        .rotationEffect(.degrees(rotation))
        .scaleEffect(reduceMotion || isPresented ? 1 : 0.82)
        .opacity(isPresented ? 1 : 0)
        .animation(
            reduceMotion
                ? nil
                : .spring(response: 0.7, dampingFraction: 0.82),
            value: isPresented
        )
    }

    private func orbitingNode(
        radius: CGFloat,
        rotation: Double,
        size: CGFloat,
        direction: Double
    ) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { trailIndex in
                Circle()
                    .fill(.secondary.opacity(0.72 - Double(trailIndex) * 0.24))
                    .frame(
                        width: size - CGFloat(trailIndex) * 1.5,
                        height: size - CGFloat(trailIndex) * 1.5
                    )
                    .offset(y: -radius)
                    .rotationEffect(
                        .degrees(
                            motionPolicy.trailRotation(
                                nodeRotation: rotation,
                                trailIndex: trailIndex,
                                direction: direction
                            )
                        )
                    )
            }
        }
        .scaleEffect(reduceMotion || isPresented ? 1 : 0.2)
        .opacity(isPresented ? 1 : 0)
        .animation(
            reduceMotion
                ? nil
                : .spring(response: 0.48, dampingFraction: 0.72)
                    .delay(0.24),
            value: isPresented
        )
    }

    private var precisionTicks: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Capsule()
                    .fill(.secondary.opacity(index.isMultiple(of: 3) ? 0.55 : 0.3))
                    .frame(
                        width: index.isMultiple(of: 3) ? 2 : 1,
                        height: index.isMultiple(of: 3) ? 8 : 5
                    )
                    .offset(y: -57)
                    .rotationEffect(.degrees(Double(index) * 30))
            }
        }
        .opacity(isPresented ? 1 : 0)
        .scaleEffect(reduceMotion || isPresented ? 1 : 0.86)
        .animation(
            reduceMotion ? nil : .easeOut(duration: 0.45).delay(0.18),
            value: isPresented
        )
    }

    private func focusCore(time: TimeInterval) -> some View {
        let pulse = motionPolicy.runsContinuously
            ? 1 + sin(time * .pi / 1.8) * 0.012
            : 1

        return Circle()
            .fill(
                LinearGradient(
                    colors: [SwishTheme.accent, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 98, height: 98)
            .scaleEffect((reduceMotion || isPresented ? 1 : 0.68) * pulse)
            .opacity(isPresented ? 1 : 0)
            .shadow(color: SwishTheme.accent.opacity(0.22), radius: 18)
            .overlay {
                Text(verbatim: "S")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .animation(
                reduceMotion
                    ? nil
                    : .spring(response: 0.52, dampingFraction: 0.7)
                        .delay(0.08),
                value: isPresented
            )
    }
}
