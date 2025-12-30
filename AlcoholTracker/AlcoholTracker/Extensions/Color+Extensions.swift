//
//  Color+Extensions.swift
//  AlcoholTracker
//
//  Color拡張
//

import SwiftUI

extension Color {
    // MARK: - App Theme Colors
    static let appPrimary = Color.orange
    static let appSecondary = Color.orange.opacity(0.7)
    static let appBackground = Color(.systemGroupedBackground)

    // MARK: - Alcohol Level Colors
    static let alcoholNone = Color.gray.opacity(0.3)
    static let alcoholLow = Color.green
    static let alcoholMedium = Color.orange
    static let alcoholHigh = Color.red

    static func alcoholLevel(for pureAlcohol: Double) -> Color {
        if pureAlcohol == 0 { return .alcoholNone }
        if pureAlcohol <= 20 { return .alcoholLow }
        if pureAlcohol <= 40 { return .alcoholMedium }
        return .alcoholHigh
    }

    // MARK: - Drink Type Colors
    static let beerColor = Color.yellow
    static let sakeColor = Color.white
    static let wineColor = Color.red.opacity(0.8)
    static let shochuColor = Color.brown.opacity(0.6)
    static let whiskeyColor = Color.orange.opacity(0.8)
    static let cocktailColor = Color.pink.opacity(0.7)

    // MARK: - Status Colors
    static let successColor = Color.green
    static let warningColor = Color.orange
    static let dangerColor = Color.red
    static let infoColor = Color.blue

    // MARK: - Gradient
    static var alcoholGradient: LinearGradient {
        LinearGradient(
            colors: [.alcoholLow, .alcoholMedium, .alcoholHigh],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var appGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .orange.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
    }

    func alcoholLevelBackground(_ pureAlcohol: Double) -> some View {
        self.background(Color.alcoholLevel(for: pureAlcohol).opacity(0.1))
    }
}
