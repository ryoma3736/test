//
//  Date+Extensions.swift
//  AlcoholTracker
//
//  Date拡張
//

import Foundation

extension Date {
    // MARK: - Formatters
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }

    var mediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }

    var longDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d(E) HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }

    // MARK: - Comparisons
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    // MARK: - Components
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var weekdayName: String {
        let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
        return weekdays[weekday - 1]
    }

    // MARK: - Arithmetic
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    // MARK: - Relative Descriptions
    var relativeDescription: String {
        if isToday {
            return "今日"
        } else if isYesterday {
            return "昨日"
        } else if isThisWeek {
            return weekdayName + "曜日"
        } else {
            return mediumDateString
        }
    }
}
