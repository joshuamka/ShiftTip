//
//  ShiftTipApp.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/3/26.
//

import SwiftUI

@main
struct ShiftTipApp: App {

    @State private var shiftTypeStore = ShiftTypeStore()
    @State private var shiftStore = ShiftStore()
    @State private var workplaceStore = WorkplaceStore()

    @AppStorage("hasSeenWelcome")
    private var hasSeenWelcome = false

    var body: some Scene {

        WindowGroup {

            Group {

                if hasSeenWelcome {

                    ContentView()

                } else {

                    WelcomeView()
                }
            }
            .environment(shiftStore)
            .environment(workplaceStore)
            .environment(shiftTypeStore)
        }
    }
}
