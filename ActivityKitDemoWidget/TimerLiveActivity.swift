//
//  TimerLiveActivity.swift
//  ActivityKitDemo
//
//  Created by Fabian Gerö on 11.11.26.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            HStack(spacing: 16) {
                Image(systemName: "timer")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.title)
                        .font(.headline)
                    countdown(for: context.state)
                        .font(.largeTitle.monospacedDigit().bold())
                }

                Spacer()
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    countdown(for: context.state)
                        .font(.title.monospacedDigit())
                        .multilineTextAlignment(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.title)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                countdown(for: context.state)
                    .monospacedDigit()
                    .frame(width: 50)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            }
        }
    }

    private func countdown(for state: TimerAttributes.ContentState) -> Text {
        Text(timerInterval: state.startDate...state.endDate, countsDown: true)
    }
}
