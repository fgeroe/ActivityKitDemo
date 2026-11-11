//
//  ActivityKitDemoWidgetBundle.swift
//  ActivityKitDemoWidget
//
//  Created by Fabian Gerö on 11.11.26.
//

import SwiftUI
import WidgetKit

@main
struct ActivityKitDemoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerLiveActivity()
    }
}
