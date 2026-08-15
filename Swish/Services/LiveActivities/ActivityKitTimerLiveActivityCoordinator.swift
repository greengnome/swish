import ActivityKit
import Foundation

@MainActor
final class ActivityKitTimerLiveActivityCoordinator: TimerLiveActivityCoordinating {
    private typealias TimerActivity = Activity<TimerLiveActivityAttributes>

    private var currentActivity: TimerActivity?
    private var pendingOperation: Task<Void, Never>?

    func synchronize(with descriptor: TimerLiveActivityDescriptor?) {
        guard let descriptor else {
            endAllActivities()
            return
        }

        let activities = knownActivities
        if let matchingActivity = activities.first(where: {
            $0.attributes.sessionID == descriptor.attributes.sessionID
        }) {
            currentActivity = matchingActivity
            end(activities.filter { $0.id != matchingActivity.id })
            update(matchingActivity, with: descriptor.contentState)
            return
        }

        currentActivity = nil
        end(activities)

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        do {
            currentActivity = try TimerActivity.request(
                attributes: descriptor.attributes,
                content: content(for: descriptor.contentState)
            )
        } catch {
            currentActivity = nil
        }
    }

    private var knownActivities: [TimerActivity] {
        var activitiesByID = Dictionary(
            uniqueKeysWithValues: TimerActivity.activities.map { ($0.id, $0) }
        )

        if let currentActivity {
            activitiesByID[currentActivity.id] = currentActivity
        }

        return Array(activitiesByID.values)
    }

    private func update(
        _ activity: TimerActivity,
        with state: TimerLiveActivityAttributes.ContentState
    ) {
        let activityContent = content(for: state)
        enqueue {
            await activity.update(activityContent)
        }
    }

    private func endAllActivities() {
        let activities = knownActivities
        currentActivity = nil
        end(activities)
    }

    private func end(_ activities: [TimerActivity]) {
        guard !activities.isEmpty else { return }

        enqueue {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    private func enqueue(
        _ operation: @escaping @MainActor () async -> Void
    ) {
        let previousOperation = pendingOperation
        pendingOperation = Task { @MainActor in
            await previousOperation?.value
            guard !Task.isCancelled else { return }
            await operation()
        }
    }

    private func content(
        for state: TimerLiveActivityAttributes.ContentState
    ) -> ActivityContent<TimerLiveActivityAttributes.ContentState> {
        ActivityContent(
            state: state,
            staleDate: staleDate(for: state)
        )
    }

    private func staleDate(
        for state: TimerLiveActivityAttributes.ContentState
    ) -> Date? {
        switch state.phase {
        case let .running(endDate):
            endDate
        case .paused:
            nil
        }
    }
}
