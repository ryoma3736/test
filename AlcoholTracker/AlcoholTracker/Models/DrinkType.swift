//
//  DrinkType.swift
//  AlcoholTracker
//
//  飲み物種類マスターデータ
//

import Foundation
import SwiftData

@Model
final class DrinkType {
    var id: UUID
    var name: String
    var emoji: String
    var defaultAlcoholPercentage: Double
    var defaultAmount: Double // ml
    var category: String
    var isCustom: Bool
    var sortOrder: Int

    init(
        name: String,
        emoji: String,
        defaultAlcoholPercentage: Double,
        defaultAmount: Double,
        category: String,
        isCustom: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.defaultAlcoholPercentage = defaultAlcoholPercentage
        self.defaultAmount = defaultAmount
        self.category = category
        self.isCustom = isCustom
        self.sortOrder = sortOrder
    }
}

// MARK: - Default Drink Types
extension DrinkType {
    static let defaultTypes: [DrinkType] = [
        // ビール系
        DrinkType(name: "ビール", emoji: "🍺", defaultAlcoholPercentage: 5.0, defaultAmount: 350, category: "ビール系", sortOrder: 1),
        DrinkType(name: "ビール(中ジョッキ)", emoji: "🍺", defaultAlcoholPercentage: 5.0, defaultAmount: 500, category: "ビール系", sortOrder: 2),
        DrinkType(name: "発泡酒", emoji: "🍺", defaultAlcoholPercentage: 5.0, defaultAmount: 350, category: "ビール系", sortOrder: 3),
        DrinkType(name: "ノンアルコールビール", emoji: "🍺", defaultAlcoholPercentage: 0.0, defaultAmount: 350, category: "ビール系", sortOrder: 4),

        // 日本酒
        DrinkType(name: "日本酒(1合)", emoji: "🍶", defaultAlcoholPercentage: 15.0, defaultAmount: 180, category: "日本酒", sortOrder: 10),
        DrinkType(name: "日本酒(グラス)", emoji: "🍶", defaultAlcoholPercentage: 15.0, defaultAmount: 90, category: "日本酒", sortOrder: 11),

        // ワイン
        DrinkType(name: "赤ワイン", emoji: "🍷", defaultAlcoholPercentage: 12.0, defaultAmount: 125, category: "ワイン", sortOrder: 20),
        DrinkType(name: "白ワイン", emoji: "🥂", defaultAlcoholPercentage: 12.0, defaultAmount: 125, category: "ワイン", sortOrder: 21),
        DrinkType(name: "スパークリングワイン", emoji: "🥂", defaultAlcoholPercentage: 12.0, defaultAmount: 125, category: "ワイン", sortOrder: 22),

        // 焼酎
        DrinkType(name: "焼酎(ロック)", emoji: "🥃", defaultAlcoholPercentage: 25.0, defaultAmount: 60, category: "焼酎", sortOrder: 30),
        DrinkType(name: "焼酎(水割り)", emoji: "🥃", defaultAlcoholPercentage: 12.5, defaultAmount: 120, category: "焼酎", sortOrder: 31),
        DrinkType(name: "チューハイ", emoji: "🍹", defaultAlcoholPercentage: 5.0, defaultAmount: 350, category: "焼酎", sortOrder: 32),
        DrinkType(name: "レモンサワー", emoji: "🍋", defaultAlcoholPercentage: 5.0, defaultAmount: 350, category: "焼酎", sortOrder: 33),

        // ウイスキー
        DrinkType(name: "ウイスキー(シングル)", emoji: "🥃", defaultAlcoholPercentage: 40.0, defaultAmount: 30, category: "ウイスキー", sortOrder: 40),
        DrinkType(name: "ウイスキー(ダブル)", emoji: "🥃", defaultAlcoholPercentage: 40.0, defaultAmount: 60, category: "ウイスキー", sortOrder: 41),
        DrinkType(name: "ハイボール", emoji: "🥃", defaultAlcoholPercentage: 7.0, defaultAmount: 350, category: "ウイスキー", sortOrder: 42),

        // カクテル
        DrinkType(name: "カクテル", emoji: "🍸", defaultAlcoholPercentage: 10.0, defaultAmount: 150, category: "カクテル", sortOrder: 50),
        DrinkType(name: "カシスオレンジ", emoji: "🍹", defaultAlcoholPercentage: 5.0, defaultAmount: 200, category: "カクテル", sortOrder: 51),
        DrinkType(name: "モヒート", emoji: "🍹", defaultAlcoholPercentage: 10.0, defaultAmount: 200, category: "カクテル", sortOrder: 52),

        // その他
        DrinkType(name: "梅酒", emoji: "🍑", defaultAlcoholPercentage: 12.0, defaultAmount: 90, category: "その他", sortOrder: 60),
        DrinkType(name: "マッコリ", emoji: "🥛", defaultAlcoholPercentage: 6.0, defaultAmount: 200, category: "その他", sortOrder: 61),
    ]
}
