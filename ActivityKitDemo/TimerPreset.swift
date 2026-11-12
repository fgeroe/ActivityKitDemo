//
//  TimerPreset.swift
//  ActivityKitDemo
//
//  Created by Fabian Gerö on 11.11.26.
//


import Foundation

struct TimerPreset: Identifiable {
    let title: String
    let symbolName: String
    let duration: TimeInterval

    var id: String { title }

    var durationText: String {
        duration < 60 ? "\(Int(duration)) Sek." : "\(Int(duration / 60)) Min."
    }

    static let all: [TimerPreset] = [
        TimerPreset(title: "Schnelltest", symbolName: "bolt.fill", duration: 30),
        TimerPreset(title: "Tee", symbolName: "cup.and.saucer.fill", duration: 3 * 60),
        TimerPreset(title: "Pasta", symbolName: "fork.knife", duration: 9 * 60),
        TimerPreset(title: "Fokus", symbolName: "brain.head.profile", duration: 25 * 60),
    ]
}
