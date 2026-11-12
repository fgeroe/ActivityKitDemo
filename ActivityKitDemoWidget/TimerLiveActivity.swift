//
//  TimerLiveActivity.swift
//  ActivityKitDemo
//
//  Created by Fabian Gerö on 11.11.26.
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.symbolName)
                        .font(.title)
                        .foregroundStyle(.orange)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CountdownText(state: context.state, isStale: context.isStale)
                        .font(.title2.monospacedDigit().bold())
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        TimerProgressBar(state: context.state, isStale: context.isStale)
                        ControlButtons(context: context)
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                Image(systemName: context.attributes.symbolName)
                    .foregroundStyle(.orange)
            } compactTrailing: {
                if context.isStale {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.orange)
                } else {
                    CountdownText(state: context.state, isStale: false)
                        .monospacedDigit()
                        .frame(width: 50)
                }
            } minimal: {
                Image(systemName: context.state.isPaused ? "pause.fill" : context.attributes.symbolName)
                    .foregroundStyle(.orange)
            }
            .keylineTint(.orange)
        }
    }
}

private struct LockScreenView: View {
    let context: ActivityViewContext<TimerAttributes>

    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: context.attributes.symbolName)
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 48, height: 48)
                    .background(Color.orange.opacity(0.2), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(context.attributes.title)
                            .font(.headline)
                        if context.state.isPaused {
                            Text("· Pausiert")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    CountdownText(state: context.state, isStale: context.isStale)
                        .font(.title.monospacedDigit().bold())
                }

                Spacer()

                if !isLuminanceReduced {
                    ControlButtons(context: context)
                }
            }

            TimerProgressBar(state: context.state, isStale: context.isStale)
        }
        .padding()
    }
}

private struct CountdownText: View {
    let state: TimerAttributes.ContentState
    let isStale: Bool

    var body: some View {
        if isStale {
            Text("Fertig!")
        } else {
            Text(timerInterval: state.startDate...state.endDate, pauseTime: state.pausedAt, countsDown: true)
        }
    }
}

private struct TimerProgressBar: View {
    let state: TimerAttributes.ContentState
    let isStale: Bool

    var body: some View {
        Group {
            if isStale {
                ProgressView(value: 1)
            } else if let pausedAt = state.pausedAt {
                ProgressView(
                    value: pausedAt.timeIntervalSince(state.startDate),
                    total: state.endDate.timeIntervalSince(state.startDate)
                )
            } else {
                ProgressView(timerInterval: state.startDate...state.endDate, countsDown: false) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                }
            }
        }
        .tint(.orange)
    }
}

private struct ControlButtons: View {
    let context: ActivityViewContext<TimerAttributes>

    var body: some View {
        HStack(spacing: 8) {
            if !context.isStale {
                Button(intent: TogglePauseIntent(activityID: context.activityID)) {
                    Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                        .font(.headline)
                        .frame(width: 40, height: 40)
                        .background(Color.orange.opacity(0.25), in: Circle())
                }
            }

            Button(intent: AddMinuteIntent(activityID: context.activityID)) {
                Text("+1")
                    .font(.headline)
                    .frame(width: 40, height: 40)
                    .background(Color.orange.opacity(0.25), in: Circle())
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.orange)
    }
}

private extension TimerAttributes {
    static let preview = TimerAttributes(title: "Tee", symbolName: "cup.and.saucer.fill")
}

private extension TimerAttributes.ContentState {
    static let running = TimerAttributes.ContentState(
        startDate: .now.addingTimeInterval(-60),
        endDate: .now.addingTimeInterval(120),
        pausedAt: nil
    )
    static let paused = TimerAttributes.ContentState(
        startDate: .now.addingTimeInterval(-60),
        endDate: .now.addingTimeInterval(120),
        pausedAt: .now
    )
}

#Preview("Lock Screen", as: .content, using: TimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    TimerAttributes.ContentState.running
    TimerAttributes.ContentState.paused
}

#Preview("Island – Expanded", as: .dynamicIsland(.expanded), using: TimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    TimerAttributes.ContentState.running
    TimerAttributes.ContentState.paused
}

#Preview("Island – Compact", as: .dynamicIsland(.compact), using: TimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    TimerAttributes.ContentState.running
}

#Preview("Island – Minimal", as: .dynamicIsland(.minimal), using: TimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    TimerAttributes.ContentState.running
    TimerAttributes.ContentState.paused
}
