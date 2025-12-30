//
//  ContentView.swift
//  AlcoholTracker
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)

            CalendarView()
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(1)

            RecordInputView()
                .tabItem {
                    Label("記録", systemImage: "plus.circle.fill")
                }
                .tag(2)

            StatsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
