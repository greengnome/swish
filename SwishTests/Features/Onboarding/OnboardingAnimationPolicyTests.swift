import Testing
@testable import Swish

struct OnboardingAnimationPolicyTests {
    @Test("An active page animates when Reduce Motion is off")
    func animatesActivePage() {
        let policy = OnboardingAnimationPolicy(
            isActive: true,
            reduceMotion: false
        )

        #expect(policy.runsEntranceAnimation)
        #expect(!policy.presentsImmediately)
    }

    @Test("Reduce Motion presents active content immediately")
    func presentsReducedMotionImmediately() {
        let policy = OnboardingAnimationPolicy(
            isActive: true,
            reduceMotion: true
        )

        #expect(!policy.runsEntranceAnimation)
        #expect(policy.presentsImmediately)
    }

    @Test("An inactive page stays reset")
    func resetsInactivePage() {
        let policy = OnboardingAnimationPolicy(
            isActive: false,
            reduceMotion: false
        )

        #expect(!policy.runsEntranceAnimation)
        #expect(!policy.presentsImmediately)
    }

    @Test("Orbital motion runs only for presented content")
    func runsOrbitalMotionForPresentedContent() {
        let activePolicy = OnboardingOrbitalMotionPolicy(
            isPresented: true,
            reduceMotion: false
        )
        let inactivePolicy = OnboardingOrbitalMotionPolicy(
            isPresented: false,
            reduceMotion: false
        )

        #expect(activePolicy.runsContinuously)
        #expect(!inactivePolicy.runsContinuously)
    }

    @Test("Reduce Motion freezes orbital motion")
    func freezesOrbitalMotionForReducedMotion() {
        let policy = OnboardingOrbitalMotionPolicy(
            isPresented: true,
            reduceMotion: true
        )

        #expect(!policy.runsContinuously)
        #expect(
            policy.rotation(
                at: 100,
                period: 10,
                offset: 42
            ) == 42
        )
    }

    @Test("Orbital rotation is deterministic")
    func calculatesOrbitalRotation() {
        let policy = OnboardingOrbitalMotionPolicy(
            isPresented: true,
            reduceMotion: false
        )

        #expect(
            policy.rotation(
                at: 2.5,
                period: 10,
                offset: 10
            ) == 100
        )
        #expect(
            policy.rotation(
                at: 2.5,
                period: 10,
                direction: -1,
                offset: 10
            ) == -80
        )
    }

    @Test("Orbital nodes stay attached to visible arc endpoints")
    func calculatesArcEndpointRotation() {
        let policy = OnboardingOrbitalMotionPolicy(
            isPresented: true,
            reduceMotion: false
        )

        #expect(
            policy.endpointRotation(
                baseRotation: 10,
                visibleFraction: 0.25
            ) == 100
        )
    }

    @Test("Orbital trails follow ring direction")
    func calculatesDirectionalTrails() {
        let policy = OnboardingOrbitalMotionPolicy(
            isPresented: true,
            reduceMotion: false
        )

        #expect(
            policy.trailRotation(
                nodeRotation: 100,
                trailIndex: 2,
                direction: 1
            ) == 91
        )
        #expect(
            policy.trailRotation(
                nodeRotation: 100,
                trailIndex: 2,
                direction: -1
            ) == 109
        )
    }
}
