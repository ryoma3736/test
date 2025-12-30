//
//  NotificationService.swift
//  AlcoholTracker
//
//  通知サービス
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    // MARK: - Permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("通知の許可リクエストに失敗: \(error)")
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Daily Reminder
    func scheduleDailyReminder(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🍺 飲酒記録"
        content.body = "今日の飲酒を記録しましょう"
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("リマインダーの設定に失敗: \(error)")
            }
        }
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }

    // MARK: - Goal Alerts
    func sendGoalExceededAlert(currentAlcohol: Double, limit: Double) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ 目標超過"
        content.body = String(format: "今日の飲酒量 %.1fg が目標 %.0fg を超えました", currentAlcohol, limit)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "goal_exceeded_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // 即時通知
        )

        UNUserNotificationCenter.current().add(request)
    }

    func sendGoalAchievedAlert(restDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 目標達成！"
        content.body = "今週の休肝日目標 \(restDays)日を達成しました！"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "goal_achieved_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Weekly Summary
    func scheduleWeeklySummary() {
        let content = UNMutableNotificationContent()
        content.title = "📊 週間サマリー"
        content.body = "今週の飲酒記録を確認しましょう"
        content.sound = .default

        // 毎週日曜日の10時
        var components = DateComponents()
        components.weekday = 1 // 日曜日
        components.hour = 10
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "weekly_summary",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Clear All
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
