//
//  StatsView.swift
//  AlcoholTracker
//
//  統計・グラフ表示画面
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkRecord.dateTime, order: .reverse) private var allRecords: [DrinkRecord]

    @State private var selectedPeriod: StatsPeriod = .week

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 期間選択
                    Picker("期間", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // 期間サマリー
                    PeriodSummaryCard(
                        records: recordsForPeriod,
                        period: selectedPeriod
                    )

                    // 日別グラフ
                    DailyAlcoholChart(
                        data: dailyChartData,
                        period: selectedPeriod
                    )

                    // 飲み物種類別円グラフ
                    DrinkTypePieChart(records: recordsForPeriod)

                    // 曜日別傾向
                    WeekdayTrendChart(records: recordsForPeriod)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("統計")
        }
    }

    // MARK: - Computed Properties
    private var recordsForPeriod: [DrinkRecord] {
        let calendar = Calendar.current
        let now = Date()

        switch selectedPeriod {
        case .week:
            guard let startDate = calendar.date(byAdding: .day, value: -7, to: now) else { return [] }
            return allRecords.filter { $0.dateTime >= startDate }
        case .month:
            guard let startDate = calendar.date(byAdding: .month, value: -1, to: now) else { return [] }
            return allRecords.filter { $0.dateTime >= startDate }
        case .year:
            guard let startDate = calendar.date(byAdding: .year, value: -1, to: now) else { return [] }
            return allRecords.filter { $0.dateTime >= startDate }
        }
    }

    private var dailyChartData: [DailyAlcoholData] {
        let calendar = Calendar.current
        let now = Date()
        var data: [DailyAlcoholData] = []

        let days = selectedPeriod == .week ? 7 : (selectedPeriod == .month ? 30 : 365)

        for dayOffset in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let dayRecords = allRecords.filter { calendar.isDate($0.dateTime, inSameDayAs: date) }
            let totalAlcohol = dayRecords.reduce(0) { $0 + $1.pureAlcohol }
            data.append(DailyAlcoholData(date: date, pureAlcohol: totalAlcohol))
        }

        return data
    }
}

// MARK: - Stats Period Enum
enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "週間"
    case month = "月間"
    case year = "年間"

    var id: String { rawValue }
}

// MARK: - Daily Alcohol Data
struct DailyAlcoholData: Identifiable {
    let id = UUID()
    let date: Date
    let pureAlcohol: Double
}

// MARK: - Period Summary Card
struct PeriodSummaryCard: View {
    let records: [DrinkRecord]
    let period: StatsPeriod

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(period.rawValue)サマリー")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 20) {
                StatBox(
                    value: String(format: "%.0f", totalPureAlcohol),
                    unit: "g",
                    label: "純アルコール"
                )

                StatBox(
                    value: "\(drinkingDays)",
                    unit: "日",
                    label: "飲酒日数"
                )

                StatBox(
                    value: "\(restDays)",
                    unit: "日",
                    label: "休肝日",
                    valueColor: restDays >= 2 ? .green : .orange
                )

                StatBox(
                    value: String(format: "%.1f", averagePerDrinkingDay),
                    unit: "g",
                    label: "平均/日"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var totalPureAlcohol: Double {
        records.reduce(0) { $0 + $1.pureAlcohol }
    }

    private var drinkingDays: Int {
        let calendar = Calendar.current
        let dates = Set(records.map { calendar.startOfDay(for: $0.dateTime) })
        return dates.count
    }

    private var restDays: Int {
        let days = period == .week ? 7 : (period == .month ? 30 : 365)
        return days - drinkingDays
    }

    private var averagePerDrinkingDay: Double {
        guard drinkingDays > 0 else { return 0 }
        return totalPureAlcohol / Double(drinkingDays)
    }
}

struct StatBox: View {
    let value: String
    let unit: String
    let label: String
    var valueColor: Color = .primary

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(valueColor)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Daily Alcohol Chart
struct DailyAlcoholChart: View {
    let data: [DailyAlcoholData]
    let period: StatsPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日別推移")
                .font(.headline)

            Chart(data) { item in
                BarMark(
                    x: .value("日付", item.date, unit: .day),
                    y: .value("純アルコール", item.pureAlcohol)
                )
                .foregroundStyle(barColor(for: item.pureAlcohol))
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                if period == .week {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                } else {
                    AxisMarks()
                }
            }

            // 凡例
            HStack(spacing: 16) {
                LegendItem(color: .green, label: "適量 (〜20g)")
                LegendItem(color: .orange, label: "注意 (20〜40g)")
                LegendItem(color: .red, label: "過剰 (40g〜)")
            }
            .font(.caption2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private func barColor(for alcohol: Double) -> Color {
        if alcohol == 0 { return .gray.opacity(0.3) }
        if alcohol <= 20 { return .green }
        if alcohol <= 40 { return .orange }
        return .red
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Drink Type Pie Chart
struct DrinkTypePieChart: View {
    let records: [DrinkRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("飲み物種類別")
                .font(.headline)

            if drinkTypeData.isEmpty {
                Text("データがありません")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                Chart(drinkTypeData) { item in
                    SectorMark(
                        angle: .value("量", item.totalAlcohol),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.0
                    )
                    .foregroundStyle(by: .value("種類", item.name))
                    .annotation(position: .overlay) {
                        Text(item.emoji)
                            .font(.title2)
                    }
                }
                .frame(height: 200)

                // 内訳リスト
                VStack(spacing: 8) {
                    ForEach(drinkTypeData.prefix(5)) { item in
                        HStack {
                            Text("\(item.emoji) \(item.name)")
                            Spacer()
                            Text(String(format: "%.1fg", item.totalAlcohol))
                                .foregroundStyle(.secondary)
                            Text(String(format: "(%.0f%%)", item.percentage))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var drinkTypeData: [DrinkTypeStats] {
        var stats: [String: (emoji: String, total: Double)] = [:]

        for record in records {
            let key = record.drinkTypeName
            if var existing = stats[key] {
                existing.total += record.pureAlcohol
                stats[key] = existing
            } else {
                stats[key] = (record.drinkTypeEmoji, record.pureAlcohol)
            }
        }

        let total = stats.values.reduce(0) { $0 + $1.total }

        return stats.map { key, value in
            DrinkTypeStats(
                name: key,
                emoji: value.emoji,
                totalAlcohol: value.total,
                percentage: total > 0 ? (value.total / total) * 100 : 0
            )
        }.sorted { $0.totalAlcohol > $1.totalAlcohol }
    }
}

struct DrinkTypeStats: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let totalAlcohol: Double
    let percentage: Double
}

// MARK: - Weekday Trend Chart
struct WeekdayTrendChart: View {
    let records: [DrinkRecord]

    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("曜日別傾向")
                .font(.headline)

            Chart(weekdayData) { item in
                BarMark(
                    x: .value("曜日", item.weekday),
                    y: .value("平均", item.averageAlcohol)
                )
                .foregroundStyle(
                    item.weekday == "金" || item.weekday == "土" ? Color.orange : Color.blue
                )
            }
            .frame(height: 150)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    private var weekdayData: [WeekdayStats] {
        let calendar = Calendar.current
        var weekdayTotals: [Int: (total: Double, count: Int)] = [:]

        for i in 1...7 {
            weekdayTotals[i] = (0, 0)
        }

        for record in records {
            let weekday = calendar.component(.weekday, from: record.dateTime)
            var current = weekdayTotals[weekday] ?? (0, 0)
            current.total += record.pureAlcohol
            current.count += 1
            weekdayTotals[weekday] = current
        }

        return (1...7).map { weekday in
            let data = weekdayTotals[weekday] ?? (0, 0)
            let average = data.count > 0 ? data.total / Double(data.count) : 0
            return WeekdayStats(weekday: weekdays[weekday - 1], averageAlcohol: average)
        }
    }
}

struct WeekdayStats: Identifiable {
    let id = UUID()
    let weekday: String
    let averageAlcohol: Double
}

#Preview {
    StatsView()
        .modelContainer(for: DrinkRecord.self, inMemory: true)
}
