//
//  DataService.swift
//  AlcoholTracker
//
//  データ管理サービス
//

import Foundation
import SwiftData

@MainActor
class DataService {
    static let shared = DataService()

    private init() {}

    // MARK: - Export
    func exportToCSV(records: [DrinkRecord]) -> String {
        var csv = "ID,日時,飲み物,絵文字,量(ml),度数(%),純アルコール(g),メモ,作成日,更新日\n"
        let formatter = ISO8601DateFormatter()

        for record in records {
            let fields = [
                record.id.uuidString,
                formatter.string(from: record.dateTime),
                record.drinkTypeName,
                record.drinkTypeEmoji,
                String(format: "%.0f", record.amount),
                String(format: "%.1f", record.alcoholPercentage),
                String(format: "%.2f", record.pureAlcohol),
                record.note ?? "",
                formatter.string(from: record.createdAt),
                formatter.string(from: record.updatedAt)
            ]

            // CSVエスケープ処理
            let escapedFields = fields.map { field -> String in
                if field.contains(",") || field.contains("\"") || field.contains("\n") {
                    return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
                }
                return field
            }

            csv += escapedFields.joined(separator: ",") + "\n"
        }

        return csv
    }

    func exportToJSON(records: [DrinkRecord]) -> String? {
        let exportRecords = records.map { record in
            ExportRecord(
                id: record.id.uuidString,
                drinkTypeName: record.drinkTypeName,
                drinkTypeEmoji: record.drinkTypeEmoji,
                amount: record.amount,
                alcoholPercentage: record.alcoholPercentage,
                pureAlcohol: record.pureAlcohol,
                dateTime: record.dateTime,
                note: record.note,
                createdAt: record.createdAt,
                updatedAt: record.updatedAt
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(exportRecords) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Statistics
    func calculateStatistics(records: [DrinkRecord]) -> DrinkStatistics {
        let totalAlcohol = records.reduce(0) { $0 + $1.pureAlcohol }
        let totalAmount = records.reduce(0) { $0 + $1.amount }

        let calendar = Calendar.current
        let drinkingDays = Set(records.map { calendar.startOfDay(for: $0.dateTime) }).count

        let drinkTypes = Dictionary(grouping: records, by: { $0.drinkTypeName })
        let mostFrequentDrink = drinkTypes.max(by: { $0.value.count < $1.value.count })?.key

        let averagePerSession = records.isEmpty ? 0 : totalAlcohol / Double(records.count)
        let averagePerDrinkingDay = drinkingDays > 0 ? totalAlcohol / Double(drinkingDays) : 0

        return DrinkStatistics(
            totalRecords: records.count,
            totalPureAlcohol: totalAlcohol,
            totalAmount: totalAmount,
            drinkingDays: drinkingDays,
            averagePerSession: averagePerSession,
            averagePerDrinkingDay: averagePerDrinkingDay,
            mostFrequentDrink: mostFrequentDrink
        )
    }

    // MARK: - Date Helpers
    func recordsForDate(_ date: Date, from records: [DrinkRecord]) -> [DrinkRecord] {
        let calendar = Calendar.current
        return records.filter { calendar.isDate($0.dateTime, inSameDayAs: date) }
    }

    func recordsForWeek(containing date: Date, from records: [DrinkRecord]) -> [DrinkRecord] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }
        return records.filter {
            $0.dateTime >= weekInterval.start && $0.dateTime < weekInterval.end
        }
    }

    func recordsForMonth(containing date: Date, from records: [DrinkRecord]) -> [DrinkRecord] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }
        return records.filter {
            $0.dateTime >= monthInterval.start && $0.dateTime < monthInterval.end
        }
    }

    // MARK: - Rest Days
    func calculateRestDays(in dateRange: ClosedRange<Date>, records: [DrinkRecord]) -> Int {
        let calendar = Calendar.current
        var restDays = 0
        var currentDate = dateRange.lowerBound

        while currentDate <= dateRange.upperBound {
            let dayRecords = recordsForDate(currentDate, from: records)
            if dayRecords.isEmpty {
                restDays += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return restDays
    }
}

// MARK: - Export Record
struct ExportRecord: Codable {
    let id: String
    let drinkTypeName: String
    let drinkTypeEmoji: String
    let amount: Double
    let alcoholPercentage: Double
    let pureAlcohol: Double
    let dateTime: Date
    let note: String?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Statistics
struct DrinkStatistics {
    let totalRecords: Int
    let totalPureAlcohol: Double
    let totalAmount: Double
    let drinkingDays: Int
    let averagePerSession: Double
    let averagePerDrinkingDay: Double
    let mostFrequentDrink: String?

    var formattedTotalAlcohol: String {
        String(format: "%.1fg", totalPureAlcohol)
    }

    var formattedAveragePerDay: String {
        String(format: "%.1fg", averagePerDrinkingDay)
    }

    var beerEquivalent: Double {
        totalPureAlcohol / 14.0
    }
}
