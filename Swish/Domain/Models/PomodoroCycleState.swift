import Foundation
import SwiftData

@Model
final class PomodoroCycleState {
    @Attribute(.unique) var id: UUID
    var completedFocusesInCycle: Int
    private var nextSuggestedKindRawValue: String

    var nextSuggestedKind: SessionKind {
        get { SessionKind(rawValue: nextSuggestedKindRawValue) ?? .focus }
        set { nextSuggestedKindRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        completedFocusesInCycle: Int = 0,
        nextSuggestedKind: SessionKind = .focus
    ) {
        self.id = id
        self.completedFocusesInCycle = max(0, completedFocusesInCycle)
        self.nextSuggestedKindRawValue = nextSuggestedKind.rawValue
    }

    func reset() {
        completedFocusesInCycle = 0
        nextSuggestedKind = .focus
    }
}
