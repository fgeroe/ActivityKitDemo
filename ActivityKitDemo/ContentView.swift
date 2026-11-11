//
//  ContentView.swift
//  ActivityKitDemo
//
//  Created by Fabian Gerö on 11.11.26.
//

import ActivityKit
import SwiftUI

struct ContentView: View {
    @State private var activity: Activity<TimerAttributes>?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "timer")
                .font(.system(size: 72))
                .foregroundStyle(.orange)

            Text(activity == nil ? "Kein Timer aktiv" : "Timer läuft")
                .font(.headline)

            VStack(spacing: 12) {
                Button("Starten (3 Min)", action: startTimer)
                    .disabled(activity != nil)

                Button("+1 Minute") {
                    Task { await addMinute() }
                }
                .disabled(activity == nil)

                Button("Beenden", role: .destructive) {
                    Task { await endTimer() }
                }
                .disabled(activity == nil)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .task {
            activity = Activity<TimerAttributes>.activities.first
        }
    }

    // MARK: - ActivityKit

    private func startTimer() {
        let state = TimerAttributes.ContentState(
            startDate: .now,
            endDate: .now.addingTimeInterval(3 * 60)
        )

        do {
            activity = try Activity.request(
                attributes: TimerAttributes(title: "Demo-Timer"),
                content: .init(state: state, staleDate: nil)
            )
        } catch {
            print("Live Activity konnte nicht gestartet werden: \(error)")
        }
    }

    private func addMinute() async {
        guard let activity else { return }

        var state = activity.content.state
        state.endDate.addTimeInterval(60)

        await activity.update(.init(state: state, staleDate: nil))
    }

    private func endTimer() async {
        await activity?.end(nil, dismissalPolicy: .immediate)
        activity = nil
    }
}

#Preview {
    ContentView()
}
