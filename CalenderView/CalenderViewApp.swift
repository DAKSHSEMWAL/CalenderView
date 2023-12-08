//
//  CalenderViewApp.swift
//  CalenderView
//
//  Created by Daksh Semwal on 08/12/23.
//

import SwiftUI

@main
struct CalenderViewApp: App {
    let sampleHolidays: [Holiday] = [
        Holiday(date: Date().addingTimeInterval(86400 * 5), occasion: "New Year's Day"), // 5 days from today
        Holiday(date: Date().addingTimeInterval(86400 * 15), occasion: "Republic Day")   // 15 days from today
    ]

    // Sample list of on leave
    let sampleOnLeave: [OnLeave] = [
        OnLeave(date: Date().addingTimeInterval(86400 * 10), count: 3), // 10 days from today, 3 people on leave
        OnLeave(date: Date().addingTimeInterval(86400 * 20), count: 2)  // 20 days from today, 2 people on leave
    ]
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: CalendarViewModel(holidays: sampleHolidays, onLeave: sampleOnLeave))
        }
    }
}
