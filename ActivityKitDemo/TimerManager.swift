//
//  TimerManager.swift
//  ActivityKitDemo
//
//  Created by Fabian Gerö on 11.11.26.
//

import ActivityKit
import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class TimerManager {
    private(set) var activity: Activity<TimerAttributes>?
    private(set) var state: TimerAttributes.ContentState?
    private(set) var areActivitiesEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
    private(set) var errorMessage: String?

    @ObservationIgnored private var observationTasks: [Task<Void, Never>] = []

    init() {
        observeAuthorization()

        if let existing = Activity<TimerAttributes>.activities.first(where: { Self.isAlive($0.activityState) }) {
            attach(to: existing)
        }
    }

    func start(_ preset: TimerPreset) {
        errorMessage = nil

        guard areActivitiesEnabled else {
            errorMessage = "Live Activities sind in den Einstellungen deaktiviert."
            return
        }

        let now = Date.now
        let attributes = TimerAttributes(title: preset.title, symbolName: preset.symbolName)
        let state = TimerAttributes.ContentState(
            startDate: now,
            endDate: now.addingTimeInterval(preset.duration),
            pausedAt: nil
        )

        do {
            let activity = try Activity.request(attributes: attributes, content: state.activityContent)
            attach(to: activity)
        } catch {
            errorMessage = "Live Activity konnte nicht gestartet werden: \(error.localizedDescription)"
        }
    }

    func togglePause() async {
        guard let activity else { return }
        await update(activity, to: activity.content.state.togglingPause())
    }

    func addMinute() async {
        guard let activity else { return }
        await update(activity, to: activity.content.state.addingMinute())
    }

    func sendAlert(after seconds: Double = 5) {
        guard let activity else { return }

        let backgroundTask = UIApplication.shared.beginBackgroundTask()

        Task {
            try? await Task.sleep(for: .seconds(seconds))

            let alert = AlertConfiguration(
                title: "\(activity.attributes.title)",
                body: "Erinnerung: Dein Timer läuft noch.",
                sound: .default
            )
            await activity.update(activity.content, alertConfiguration: alert)

            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }

    func stop() async {
        guard let activity else { return }

        await activity.end(nil, dismissalPolicy: .immediate)
        detach()
    }

    func refresh() {
        guard let activity else { return }

        if Self.isAlive(activity.activityState) {
            state = activity.content.state
        } else {
            detach()
        }
    }

    private func update(_ activity: Activity<TimerAttributes>, to newState: TimerAttributes.ContentState) async {
        state = newState
        await activity.update(newState.activityContent)
    }

    private func attach(to activity: Activity<TimerAttributes>) {
        self.activity = activity
        self.state = activity.content.state

        observationTasks.forEach { $0.cancel() }
        observationTasks = [
            Task { [weak self] in
                for await content in activity.contentUpdates {
                    self?.state = content.state
                }
            },
            Task { [weak self] in
                for await activityState in activity.activityStateUpdates where !Self.isAlive(activityState) {
                    self?.detach()
                }
            },
        ]
    }

    private func detach() {
        observationTasks.forEach { $0.cancel() }
        observationTasks = []
        activity = nil
        state = nil
    }

    private func observeAuthorization() {
        Task { [weak self] in
            for await enabled in ActivityAuthorizationInfo().activityEnablementUpdates {
                self?.areActivitiesEnabled = enabled
            }
        }
    }

    private static func isAlive(_ activityState: ActivityState) -> Bool {
        activityState == .active || activityState == .stale
    }
}
