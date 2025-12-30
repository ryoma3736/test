//
//  DrinkRecord.swift
//  AlcoholTracker
//
//  飲酒記録モデル
//

import Foundation
import SwiftData

@Model
final class DrinkRecord {
    var id: UUID
    var drinkTypeName: String
    var drinkTypeEmoji: String
    var amount: Double // ml
    var alcoholPercentage: Double // %
    var pureAlcohol: Double // g (自動計算)
    var dateTime: Date
    var note: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        drinkTypeName: String,
        drinkTypeEmoji: String,
        amount: Double,
        alcoholPercentage: Double,
        dateTime: Date = Date(),
        note: String? = nil
    ) {
        self.id = UUID()
        self.drinkTypeName = drinkTypeName
        self.drinkTypeEmoji = drinkTypeEmoji
        self.amount = amount
        self.alcoholPercentage = alcoholPercentage
        // 純アルコール量(g) = 飲酒量(ml) × アルコール度数(%) × 0.8(アルコール比重)
        self.pureAlcohol = amount * (alcoholPercentage / 100) * 0.8
        self.dateTime = dateTime
        self.note = note
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // 純アルコール量を再計算
    func recalculatePureAlcohol() {
        self.pureAlcohol = amount * (alcoholPercentage / 100) * 0.8
        self.updatedAt = Date()
    }
}

// MARK: - Computed Properties
extension DrinkRecord {
    var formattedAmount: String {
        if amount >= 1000 {
            return String(format: "%.1fL", amount / 1000)
        } else {
            return String(format: "%.0fml", amount)
        }
    }

    var formattedPureAlcohol: String {
        return String(format: "%.1fg", pureAlcohol)
    }

    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(E) HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: dateTime)
    }

    var displayName: String {
        return "\(drinkTypeEmoji) \(drinkTypeName)"
    }
}
