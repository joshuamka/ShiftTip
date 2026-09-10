//
//  ContentView.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/3/26.
//

// Background: #101010
//Card:       #1E1E1E
//Primary:    #FF2D55
//Success:    #00C853
//White:      #FFFFFF
//Gray:       #A6A6A6

import SwiftUI

struct ContentView: View {

    private let accentColor = Color(
        red: 1.0,
        green: 0.176,
        blue: 0.333
    )

    var body: some View {

        TabView {

            DashboardView()
                .tabItem {
                    Label(
                        "Dashboard",
                        systemImage: "house.fill"
                    )
                }

            AddShiftView()
                .tabItem {
                    Label(
                        "Add Shift",
                        systemImage: "plus.circle.fill"
                    )
                }

            HistoryView()
                .tabItem {
                    Label(
                        "History",
                        systemImage: "clock.arrow.circlepath"
                    )
                }

            AnalyticsView()
                .tabItem {
                    Label(
                        "Analytics",
                        systemImage: "chart.bar.fill"
                    )
                }

            ProfileView()
                .tabItem {
                    Label(
                        "Profile",
                        systemImage: "person.fill"
                    )
                }
        }
        .tint(accentColor)
        .toolbarBackground(
            .visible,
            for: .tabBar
        )
        .toolbarBackground(
            Color(.secondarySystemGroupedBackground),
            for: .tabBar
        )
    }
}

#Preview {
    ContentView()
        .environment(
            ShiftStore()
        )
}
