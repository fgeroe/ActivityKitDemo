//
//  TimerIntents.swift
//  ActivityKitDemo
//
//  Created by Fabian Gerö on 11.11.26.
//


import ActivityKit
import AppIntents

nonisolated struct TogglePauseIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Timer pausieren oder fortsetzen"
    static let isDiscoverable = false

    @Parameter(title: "Activity-ID")
    var activityID: String

    init() {}

    init(activityID: String) {
        self.activityID = activityID
    }

    func perform() async throws -> some IntentResult {
        if let activity = Activity<TimerAttributes>.activities.first(where: { $0.id == activityID }) {
            let newState = activity.content.state.togglingPause()
            await activity.update(newState.activityContent)
        }
        return .result()
    }
}

nonisolated struct AddMinuteIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Eine Minute hinzufügen"
    static let isDiscoverable = false

    @Parameter(title: "Activity-ID")
    var activityID: String

    init() {}

    init(activityID: String) {
        self.activityID = activityID
    }

    func perform() async throws -> some IntentResult {
        if let activity = Activity<TimerAttributes>.activities.first(where: { $0.id == activityID }) {
            let newState = activity.content.state.addingMinute()
            await activity.update(newState.activityContent)
        }
        return .result()
    }
}
