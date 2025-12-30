//
//  CalendarView.swift
//  AlcoholTracker
//
//  カレンダー表示画面
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkRecord.dateTime, order: .reverse) private var allRecords: [DrinkRecord]

    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 月選択ヘッダー
                    MonthNavigationHeader(
                        currentMonth: $currentMonth,
                        calendar: calendar
                    )

                    // 曜日ヘッダー
                    HStack {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(day == "日" ? .red : (day == "土" ? .blue : .primary))
                                .frame(maxWidth: .infinity)
                        }
                    }

                    // カレンダーグリッド
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(daysInMonth, id: \.self) { date in
                            if let date = date {
                                CalendarDayCell(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(date),
                                    records: recordsForDate(date),
                                    onTap: { selectedDate = date }
                                )
                            } else {
                                Color.clear
                                    .frame(height: 50)
                            }
                        }
                    }

                    Divider()

                    // 選択日の記録詳細
                    SelectedDateRecordsView(
                        date: selectedDate,
                        records: recordsForDate(selectedDate)
                    )
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("カレンダー")
        }
    }

    // MARK: - Computed Properties
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []

        // 月の最初の週の開始日から
        var current = monthFirstWeek.start

        // 6週分のセルを生成
        for _ in 0..<42 {
            if calendar.isDate(current, equalTo: currentMonth, toGranularity: .month) {
                days.append(current)
            } else if days.isEmpty || days.last != nil {
                days.append(nil)
            }
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }

        // 末尾のnilを削除
        while days.last == nil {
            days.removeLast()
        }

        return days
    }

    private func recordsForDate(_ date: Date) -> [DrinkRecord] {
        allRecords.filter { calendar.isDate($0.dateTime, inSameDayAs: date) }
    }
}

// MARK: - Month Navigation Header
struct MonthNavigationHeader: View {
    @Binding var currentMonth: Date
    let calendar: Calendar

    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }

            Spacer()

            Text(monthYearString)
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
        .padding(.horizontal)
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }

    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let records: [DrinkRecord]
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(textColor)

                // 飲酒量インジケーター
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 8, height: 8)
                    .opacity(records.isEmpty ? 0 : 1)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
    }

    private var textColor: Color {
        let weekday = calendar.component(.weekday, from: date)
        if isToday { return .orange }
        if weekday == 1 { return .red }
        if weekday == 7 { return .blue }
        return .primary
    }

    private var backgroundColor: Color {
        if isSelected { return Color.orange.opacity(0.1) }
        if isToday { return Color.orange.opacity(0.05) }
        return Color(.systemBackground)
    }

    private var indicatorColor: Color {
        let totalAlcohol = records.reduce(0) { $0 + $1.pureAlcohol }
        if totalAlcohol == 0 { return .clear }
        if totalAlcohol <= 20 { return .green }
        if totalAlcohol <= 40 { return .orange }
        return .red
    }
}

// MARK: - Selected Date Records View
struct SelectedDateRecordsView: View {
    let date: Date
    let records: [DrinkRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateString)
                    .font(.headline)
                Spacer()
                if records.isEmpty {
                    Text("休肝日 🎉")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                } else {
                    Text(String(format: "%.1fg", totalPureAlcohol))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if records.isEmpty {
                Text("この日の記録はありません")
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

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private var totalPureAlcohol: Double {
        records.reduce(0) { $0 + $1.pureAlcohol }
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: DrinkRecord.self, inMemory: true)
}
