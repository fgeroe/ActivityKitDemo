//
//  ContentView.swift
//  ActivityKitDemo
//
//  Created by Fabian Gerö on 11.11.26.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var manager = TimerManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !manager.areActivitiesEnabled {
                        DisabledBanner()
                    }

                    if let activity = manager.activity, let state = manager.state {
                        RunningTimerView(attributes: activity.attributes, state: state, manager: manager)
                    } else {
                        PresetGrid { preset in
                            manager.start(preset)
                        }
                    }

                    if let errorMessage = manager.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Live Activity Demo")
        }
        .tint(.orange)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                manager.refresh()
            }
        }
    }
}

private struct PresetGrid: View {
    let onSelect: (TimerPreset) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timer wählen")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(TimerPreset.all) { preset in
                    Button {
                        onSelect(preset)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: preset.symbolName)
                                .font(.title)
                                .foregroundStyle(.orange)
                            Text(preset.title)
                                .font(.headline)
                            Text(preset.durationText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }

        }
    }
}

private struct RunningTimerView: View {
    let attributes: TimerAttributes
    let state: TimerAttributes.ContentState
    let manager: TimerManager

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: attributes.symbolName)
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)
                Text(attributes.title)
                    .font(.title2.bold())
            }

            Group {
                if let pausedText = state.pausedRemainingText {
                    Text(pausedText)
                } else {
                    Text(timerInterval: state.startDate...state.endDate, countsDown: true)
                }
            }
            .font(.system(size: 64, weight: .bold, design: .rounded).monospacedDigit())
            .multilineTextAlignment(.center)

            TimelineView(.periodic(from: .now, by: 1)) { context in
                StatusLabel(state: state, now: context.date)
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        Task { await manager.togglePause() }
                    } label: {
                        Label(
                            state.isPaused ? "Weiter" : "Pause",
                            systemImage: state.isPaused ? "play.fill" : "pause.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }

                    Button {
                        Task { await manager.addMinute() }
                    } label: {
                        Label("+1 Min", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                }

                Button {
                    manager.sendAlert(after: 5)
                } label: {
                    Label("Alert in 5 Sek.", systemImage: "bell.badge")
                        .frame(maxWidth: .infinity)
                }

                Button(role: .destructive) {
                    Task { await manager.stop() }
                } label: {
                    Label("Beenden", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

        }
    }
}

private struct StatusLabel: View {
    let state: TimerAttributes.ContentState
    let now: Date

    var body: some View {
        Group {
            if state.isPaused {
                Label("Pausiert", systemImage: "pause.circle.fill")
            } else if state.isFinished(at: now) {
                Label("Fertig!", systemImage: "checkmark.circle.fill")
            } else {
                Label("Läuft", systemImage: "play.circle.fill")
            }
        }
        .font(.headline)
        .foregroundStyle(.secondary)
    }
}

private struct DisabledBanner: View {
    var body: some View {
        Label(
            "Live Activities sind für diese App in den Einstellungen deaktiviert.",
            systemImage: "exclamationmark.triangle.fill"
        )
        .font(.callout)
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
