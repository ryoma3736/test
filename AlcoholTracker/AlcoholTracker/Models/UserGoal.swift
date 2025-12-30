//
//  UserGoal.swift
//  AlcoholTracker
//
//  ユーザー目標設定モデル
//

import Foundation
import SwiftData

@Model
final class UserGoal {
    var id: UUID
    var weeklyPureAlcoholLimit: Double // 週間純アルコール量上限(g)
    var weeklyRestDaysTarget: Int // 週間休肝日目標
    var dailyPureAlcoholLimit: Double // 1日の純アルコール量上限(g)
    var reminderEnabled: Bool
    var reminderTime: Date
    var createdAt: Date
    var updatedAt: Date

    init(
        weeklyPureAlcoholLimit: Double = 140.0, // 厚労省推奨: 週140g以下
        weeklyRestDaysTarget: Int = 2,
        dailyPureAlcoholLimit: Double = 40.0, // 1日40g以下
        reminderEnabled: Bool = true,
        reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    ) {
        self.id = UUID()
        self.weeklyPureAlcoholLimit = weeklyPureAlcoholLimit
        self.weeklyRestDaysTarget = weeklyRestDaysTarget
        self.dailyPureAlcoholLimit = dailyPureAlcoholLimit
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Computed Properties
extension UserGoal {
    var formattedWeeklyLimit: String {
        return String(format: "%.0fg", weeklyPureAlcoholLimit)
    }

    var formattedDailyLimit: String {
        return String(format: "%.0fg", dailyPureAlcoholLimit)
    }

    var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: reminderTime)
    }

    // ビール換算(5%, 350ml = 14gアルコール)
    var weeklyBeerEquivalent: Int {
        return Int(weeklyPureAlcoholLimit / 14.0)
    }

    var dailyBeerEquivalent: Double {
        return dailyPureAlcoholLimit / 14.0
    }
}

// MARK: - Health Guidelines
extension UserGoal {
    static let healthGuidelines = """
    【厚生労働省の適正飲酒ガイドライン】

    ・1日の適量: 純アルコール20g程度
      - ビール中ビン1本 (500ml)
      - 日本酒1合 (180ml)
      - ワイン2杯 (200ml)

    ・週に2日は休肝日を設ける

    ・女性や高齢者は上記の1/2〜2/3程度

    ※個人差があります。体調に合わせて調整してください。
    """
}
