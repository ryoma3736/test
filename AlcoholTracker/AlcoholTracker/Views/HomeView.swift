//
//  HomeView.swift
//  AlcoholTracker
//
//  ホーム画面 - 今日の記録サマリー
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkRecord.dateTime, order: .reverse) private var allRecords: [DrinkRecord]
    @State private var showingAddRecord = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 今日のサマリーカード
                    TodaySummaryCard(
                        todayRecords: todayRecords,
                        totalPureAlcohol: todayTotalPureAlcohol
                    )

                    // クイック記録ボタン
                    QuickRecordSection(onAddRecord: { showingAddRecord = true })

                    // 今日の記録リスト
                    TodayRecordsSection(records: todayRecords)

                    // 今週のサマリー
                    WeeklySummaryCard(
                        weekRecords: thisWeekRecords,
                        restDays: thisWeekRestDays
                    )
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("🍺 飲酒記録")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddRecord = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecord) {
                RecordInputView()
            }
        }
    }

    // MARK: - Computed Properties
    private var todayRecords: [DrinkRecord] {
        allRecords.filter { Calendar.current.isDateInToday($0.dateTime) }
    }

    private var todayTotalPureAlcohol: Double {
        todayRecords.reduce(0) { $0 + $1.pureAlcohol }
    }

    private var thisWeekRecords: [DrinkRecord] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return []
        }
        return allRecords.filter { $0.dateTime >= weekStart }
    }

    private var thisWeekRestDays: Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return 0
        }

        var restDays = 0
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart),
                  date <= now else { continue }

            let dayRecords = allRecords.filter { calendar.isDate($0.dateTime, inSameDayAs: date) }
            if dayRecords.isEmpty {
                restDays += 1
            }
        }
        return restDays
    }
}

// MARK: - Today Summary Card
struct TodaySummaryCard: View {
    let todayRecords: [DrinkRecord]
    let totalPureAlcohol: Double

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日の飲酒量")
                    .font(.headline)
                Spacer()
                Text(todayRecords.isEmpty ? "休肝日 🎉" : "")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }

            HStack(alignment: .bottom, spacing: 4) {
                Text(String(format: "%.1f", totalPureAlcohol))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(alcoholLevelColor)
                Text("g")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)

                Spacer()

                VStack(alignment: .trailing) {
                    Text("純アルコール量")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("目安: \(beerEquivalent)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // プログレスバー (1日の目安40gに対して)
            ProgressView(value: min(totalPureAlcohol / 40.0, 1.0))
                .tint(alcoholLevelColor)

            HStack {
                Text("0g")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("適量 20g")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("40g")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var alcoholLevelColor: Color {
        if totalPureAlcohol == 0 { return .green }
        if totalPureAlcohol <= 20 { return .blue }
        if totalPureAlcohol <= 40 { return .orange }
        return .red
    }

    private var beerEquivalent: String {
        let beers = totalPureAlcohol / 14.0 // ビール350ml = 14g
        if beers < 0.1 { return "ビール0本" }
        return String(format: "ビール%.1f本", beers)
    }
}

// MARK: - Quick Record Section
struct QuickRecordSection: View {
    let onAddRecord: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("クイック記録")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickRecordButton(emoji: "🍺", name: "ビール", onTap: onAddRecord)
                    QuickRecordButton(emoji: "🍶", name: "日本酒", onTap: onAddRecord)
                    QuickRecordButton(emoji: "🍷", name: "ワイン", onTap: onAddRecord)
                    QuickRecordButton(emoji: "🥃", name: "ハイボール", onTap: onAddRecord)
                    QuickRecordButton(emoji: "🍹", name: "サワー", onTap: onAddRecord)
                }
            }
        }
    }
}

struct QuickRecordButton: View {
    let emoji: String
    let name: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.largeTitle)
                Text(name)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(width: 70, height: 80)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3)
        }
    }
}

// MARK: - Today Records Section
struct TodayRecordsSection: View {
    let records: [DrinkRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の記録")
                .font(.headline)

            if records.isEmpty {
                Text("まだ記録がありません")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
            } else {
                ForEach(records) { record in
                    RecordRowView(record: record)
                }
            }
        }
    }
}

struct RecordRowView: View {
    let record: DrinkRecord

    var body: some View {
        HStack {
            Text(record.drinkTypeEmoji)
                .font(.title)

            VStack(alignment: .leading) {
                Text(record.drinkTypeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(record.formattedDateTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(record.formattedAmount)
                    .font(.subheadline)
                Text(record.formattedPureAlcohol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Weekly Summary Card
struct WeeklySummaryCard: View {
    let weekRecords: [DrinkRecord]
    let restDays: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今週のサマリー")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 20) {
                VStack {
                    Text(String(format: "%.0f", weekTotalPureAlcohol))
                        .font(.title)
                        .fontWeight(.bold)
                    Text("g")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("純アルコール")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack {
                    Text("\(restDays)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(restDays >= 2 ? .green : .orange)
                    Text("日")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("休肝日")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack {
                    Text("\(weekRecords.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("回")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("飲酒回数")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var weekTotalPureAlcohol: Double {
        weekRecords.reduce(0) { $0 + $1.pureAlcohol }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: DrinkRecord.self, inMemory: true)
}
