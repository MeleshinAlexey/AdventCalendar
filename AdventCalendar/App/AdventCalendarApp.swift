//
//  AdventCalendarApp.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/20/26.
//

import Foundation
import SwiftUI

@main
struct AdventCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                // Lock appearance for the whole app starting at the entry point.
                .preferredColorScheme(.light)
                .environment(\.colorScheme, .light)
        }
    }
}
