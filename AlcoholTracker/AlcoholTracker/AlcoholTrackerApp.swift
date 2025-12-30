//
//  AlcoholTrackerApp.swift
//  AlcoholTracker - 飲酒記録アプリ
//
//  Created by Miyabi Agent
//

import SwiftUI
import SwiftData

@main
struct AlcoholTrackerApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: DrinkRecord.self, DrinkType.self, UserGoal.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
