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
    }

    var title: String
}
