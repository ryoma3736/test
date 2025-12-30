//
//  SettingsView.swift
//  AlcoholTracker
//
//  設定画面
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [UserGoal]

    @State private var weeklyLimit: Double = 140.0
    @State private var dailyLimit: Double = 40.0
    @State private var restDaysTarget: Int = 2
    @State private var reminderEnabled: Bool = true
    @State private var reminderTime: Date = Date()
    @State private var showingExportSheet = false
    @State private var showingHealthGuidelines = false

    var body: some View {
        NavigationStack {
            Form {
                // 目標設定セクション
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("週間純アルコール上限")
                            Spacer()
                            Text(String(format: "%.0fg", weeklyLimit))
                                .fontWeight(.semibold)
                        }
                        Slider(value: $weeklyLimit, in: 0...300, step: 10)
                            .tint(.orange)
                        Text("ビール約\(Int(weeklyLimit / 14))本相当")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("1日の純アルコール上限")
                            Spacer()
                            Text(String(format: "%.0fg", dailyLimit))
                                .fontWeight(.semibold)
                        }
                        Slider(value: $dailyLimit, in: 0...100, step: 5)
                            .tint(.orange)
                    }

                    Stepper("週間休肝日目標: \(restDaysTarget)日", value: $restDaysTarget, in: 0...7)
                } header: {
                    Text("目標設定")
                } footer: {
                    Button("厚労省ガイドラインを見る") {
                        showingHealthGuidelines = true
                    }
                    .font(.caption)
                }

                // 通知設定セクション
                Section {
                    Toggle("リマインダー通知", isOn: $reminderEnabled)

                    if reminderEnabled {
                        DatePicker(
                            "通知時刻",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("通知設定")
                } footer: {
                    Text("毎日指定時刻に記録を促す通知が届きます")
                }

                // データ管理セクション
                Section {
                    Button(action: { showingExportSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("データをエクスポート")
                        }
                    }

                    NavigationLink {
                        DataManagementView()
                    } label: {
                        HStack {
                            Image(systemName: "externaldrive")
                            Text("データ管理")
                        }
                    }
                } header: {
                    Text("データ")
                }

                // アプリ情報セクション
                Section {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Text("プライバシーポリシー")
                    }

                    NavigationLink {
                        LicenseView()
                    } label: {
                        Text("ライセンス")
                    }
                } header: {
                    Text("アプリ情報")
                }
            }
            .navigationTitle("設定")
            .onAppear {
                loadGoals()
            }
            .onChange(of: weeklyLimit) { _, _ in saveGoals() }
            .onChange(of: dailyLimit) { _, _ in saveGoals() }
            .onChange(of: restDaysTarget) { _, _ in saveGoals() }
            .onChange(of: reminderEnabled) { _, _ in saveGoals() }
            .onChange(of: reminderTime) { _, _ in saveGoals() }
            .sheet(isPresented: $showingExportSheet) {
                ExportDataView()
            }
            .sheet(isPresented: $showingHealthGuidelines) {
                HealthGuidelinesView()
            }
        }
    }

    // MARK: - Data Management
    private func loadGoals() {
        if let goal = goals.first {
            weeklyLimit = goal.weeklyPureAlcoholLimit
            dailyLimit = goal.dailyPureAlcoholLimit
            restDaysTarget = goal.weeklyRestDaysTarget
            reminderEnabled = goal.reminderEnabled
            reminderTime = goal.reminderTime
        }
    }

    private func saveGoals() {
        if let goal = goals.first {
            goal.weeklyPureAlcoholLimit = weeklyLimit
            goal.dailyPureAlcoholLimit = dailyLimit
            goal.weeklyRestDaysTarget = restDaysTarget
            goal.reminderEnabled = reminderEnabled
            goal.reminderTime = reminderTime
            goal.updatedAt = Date()
        } else {
            let newGoal = UserGoal(
                weeklyPureAlcoholLimit: weeklyLimit,
                weeklyRestDaysTarget: restDaysTarget,
                dailyPureAlcoholLimit: dailyLimit,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime
            )
            modelContext.insert(newGoal)
        }
    }
}

// MARK: - Data Management View
struct DataManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allRecords: [DrinkRecord]
    @State private var showingDeleteConfirmation = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("総記録数")
                    Spacer()
                    Text("\(allRecords.count)件")
                        .foregroundStyle(.secondary)
                }

                if let firstRecord = allRecords.last {
                    HStack {
                        Text("最初の記録")
                        Spacer()
                        Text(firstRecord.formattedDateTime)
                            .foregroundStyle(.secondary)
                    }
                }

                if let lastRecord = allRecords.first {
                    HStack {
                        Text("最新の記録")
                        Spacer()
                        Text(lastRecord.formattedDateTime)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("データ統計")
            }

            Section {
                Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("全データを削除")
                    }
                }
            } header: {
                Text("危険な操作")
            } footer: {
                Text("この操作は取り消せません。すべての飲酒記録が削除されます。")
            }
        }
        .navigationTitle("データ管理")
        .alert("全データを削除しますか？", isPresented: $showingDeleteConfirmation) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("この操作は取り消せません。")
        }
    }

    private func deleteAllData() {
        for record in allRecords {
            modelContext.delete(record)
        }
    }
}

// MARK: - Export Data View
struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \DrinkRecord.dateTime, order: .reverse) private var allRecords: [DrinkRecord]

    @State private var exportFormat: ExportFormat = .csv
    @State private var exportedURL: URL?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("形式", selection: $exportFormat) {
                        ForEach(ExportFormat.allCases) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                } header: {
                    Text("エクスポート形式")
                }

                Section {
                    HStack {
                        Text("エクスポート件数")
                        Spacer()
                        Text("\(allRecords.count)件")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(action: exportData) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                            Text("エクスポート")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("データエクスポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func exportData() {
        // エクスポート処理（簡略化）
        let csvContent = generateCSV()
        print(csvContent)
        // 実際のアプリではShareSheetを表示
    }

    private func generateCSV() -> String {
        var csv = "日時,飲み物,量(ml),度数(%),純アルコール(g),メモ\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        for record in allRecords {
            let line = "\(formatter.string(from: record.dateTime)),\(record.drinkTypeName),\(record.amount),\(record.alcoholPercentage),\(record.pureAlcohol),\(record.note ?? "")\n"
            csv += line
        }

        return csv
    }
}

enum ExportFormat: String, CaseIterable, Identifiable {
    case csv = "CSV"
    case json = "JSON"

    var id: String { rawValue }
}

// MARK: - Health Guidelines View
struct HealthGuidelinesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(UserGoal.healthGuidelines)
                        .padding()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("純アルコール量の目安")
                            .font(.headline)

                        DrinkReferenceRow(emoji: "🍺", name: "ビール中ビン1本", amount: "500ml", alcohol: "約20g")
                        DrinkReferenceRow(emoji: "🍶", name: "日本酒1合", amount: "180ml", alcohol: "約22g")
                        DrinkReferenceRow(emoji: "🍷", name: "ワイン2杯", amount: "200ml", alcohol: "約20g")
                        DrinkReferenceRow(emoji: "🥃", name: "ウイスキーダブル", amount: "60ml", alcohol: "約20g")
                        DrinkReferenceRow(emoji: "🍹", name: "チューハイ(7%)", amount: "350ml", alcohol: "約20g")
                    }
                    .padding()
                }
            }
            .navigationTitle("適正飲酒ガイドライン")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

struct DrinkReferenceRow: View {
    let emoji: String
    let name: String
    let amount: String
    let alcohol: String

    var body: some View {
        HStack {
            Text(emoji)
                .font(.title2)
            VStack(alignment: .leading) {
                Text(name)
                Text(amount)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(alcohol)
                .fontWeight(.medium)
                .foregroundStyle(.orange)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("プライバシーポリシー")
                    .font(.title)
                    .fontWeight(.bold)

                Text("""
                本アプリは、ユーザーの飲酒記録を管理するためのアプリです。

                【収集する情報】
                ・飲酒記録（飲み物の種類、量、日時）
                ・目標設定値

                【情報の保存】
                すべてのデータはお使いのデバイス内にのみ保存されます。
                外部サーバーへの送信は行いません。

                【iCloud同期】
                iCloud同期を有効にした場合、データは暗号化された状態でiCloudに保存されます。

                【お問い合わせ】
                ご質問やご要望は、App Storeのレビュー機能よりお寄せください。
                """)
                .padding()
            }
            .padding()
        }
        .navigationTitle("プライバシーポリシー")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - License View
struct LicenseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("ライセンス")
                    .font(.title)
                    .fontWeight(.bold)

                Text("""
                AlcoholTracker

                Copyright © 2024 Miyabi Agent

                このアプリはSwiftUIとSwiftDataを使用して構築されています。

                【使用ライブラリ】
                ・SwiftUI (Apple)
                ・SwiftData (Apple)
                ・Charts (Apple)

                すべてApple標準フレームワークを使用しています。
                """)
                .padding()
            }
            .padding()
        }
        .navigationTitle("ライセンス")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [DrinkRecord.self, UserGoal.self], inMemory: true)
}
