//
//  TimerAttributes.swift
//  ActivityKitDemo
//
//  Created by Fabian Gerö on 11.11.26.
//


import ActivityKit
import Foundation

nonisolated struct TimerAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var startDate: Date
        var endDate: Date
        var pausedAt: Date?

        var isPaused: Bool { pausedAt != nil }

        func isFinished(at now: Date = .now) -> Bool {
            !isPaused && endDate <= now
        }

        var staleDate: Date? {
            isPaused ? nil : endDate
        }

        var activityContent: ActivityContent<Self> {
            ActivityContent(state: self, staleDate: staleDate)
        }

        func togglingPause(at now: Date = .now) -> Self {
            var copy = self
            if let pausedAt {
                let pauseDuration = now.timeIntervalSince(pausedAt)
                copy.startDate.addTimeInterval(pauseDuration)
                copy.endDate.addTimeInterval(pauseDuration)
                copy.pausedAt = nil
            } else if !isFinished(at: now) {
                copy.pausedAt = now
            }
            return copy
        }

        func addingMinute(at now: Date = .now) -> Self {
            var copy = self
            if isFinished(at: now) {
                copy.startDate = now
                copy.endDate = now.addingTimeInterval(60)
            } else {
                copy.endDate.addTimeInterval(60)
            }
            return copy
        }
    }

    var title: String
    var symbolName: String
}
