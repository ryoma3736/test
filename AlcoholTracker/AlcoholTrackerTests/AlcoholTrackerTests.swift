//
//  AlcoholTrackerTests.swift
//  AlcoholTrackerTests
//
//  Unit Tests
//

import XCTest
import SwiftData
@testable import AlcoholTracker

final class AlcoholTrackerTests: XCTestCase {

    // MARK: - DrinkRecord Tests
    func testPureAlcoholCalculation() {
        // ビール 350ml 5%
        let beer = DrinkRecord(
            drinkTypeName: "ビール",
            drinkTypeEmoji: "🍺",
            amount: 350,
            alcoholPercentage: 5.0
        )
        // 350 * 0.05 * 0.8 = 14g
        XCTAssertEqual(beer.pureAlcohol, 14.0, accuracy: 0.01)
    }

    func testPureAlcoholCalculationSake() {
        // 日本酒 180ml 15%
        let sake = DrinkRecord(
            drinkTypeName: "日本酒",
            drinkTypeEmoji: "🍶",
            amount: 180,
            alcoholPercentage: 15.0
        )
        // 180 * 0.15 * 0.8 = 21.6g
        XCTAssertEqual(sake.pureAlcohol, 21.6, accuracy: 0.01)
    }

    func testPureAlcoholCalculationWine() {
        // ワイン 125ml 12%
        let wine = DrinkRecord(
            drinkTypeName: "ワイン",
            drinkTypeEmoji: "🍷",
            amount: 125,
            alcoholPercentage: 12.0
        )
        // 125 * 0.12 * 0.8 = 12g
        XCTAssertEqual(wine.pureAlcohol, 12.0, accuracy: 0.01)
    }

    func testPureAlcoholCalculationWhiskey() {
        // ウイスキー 30ml 40%
        let whiskey = DrinkRecord(
            drinkTypeName: "ウイスキー",
            drinkTypeEmoji: "🥃",
            amount: 30,
            alcoholPercentage: 40.0
        )
        // 30 * 0.40 * 0.8 = 9.6g
        XCTAssertEqual(whiskey.pureAlcohol, 9.6, accuracy: 0.01)
    }

    func testZeroAlcohol() {
        // ノンアルコール 350ml 0%
        let nonAlc = DrinkRecord(
            drinkTypeName: "ノンアルコールビール",
            drinkTypeEmoji: "🍺",
            amount: 350,
            alcoholPercentage: 0.0
        )
        XCTAssertEqual(nonAlc.pureAlcohol, 0.0, accuracy: 0.01)
    }

    // MARK: - DrinkType Tests
    func testDefaultDrinkTypesExist() {
        let types = DrinkType.defaultTypes
        XCTAssertGreaterThan(types.count, 0)
    }

    func testBeerTypeExists() {
        let beer = DrinkType.defaultTypes.first { $0.name == "ビール" }
        XCTAssertNotNil(beer)
        XCTAssertEqual(beer?.defaultAlcoholPercentage, 5.0)
        XCTAssertEqual(beer?.defaultAmount, 350)
    }

    func testSakeTypeExists() {
        let sake = DrinkType.defaultTypes.first { $0.name == "日本酒(1合)" }
        XCTAssertNotNil(sake)
        XCTAssertEqual(sake?.defaultAlcoholPercentage, 15.0)
        XCTAssertEqual(sake?.defaultAmount, 180)
    }

    // MARK: - UserGoal Tests
    func testDefaultGoalValues() {
        let goal = UserGoal()
        XCTAssertEqual(goal.weeklyPureAlcoholLimit, 140.0)
        XCTAssertEqual(goal.weeklyRestDaysTarget, 2)
        XCTAssertEqual(goal.dailyPureAlcoholLimit, 40.0)
        XCTAssertTrue(goal.reminderEnabled)
    }

    func testBeerEquivalent() {
        let goal = UserGoal(weeklyPureAlcoholLimit: 140.0)
        // 140g / 14g per beer = 10 beers
        XCTAssertEqual(goal.weeklyBeerEquivalent, 10)
    }

    // MARK: - Date Extension Tests
    func testStartOfDay() {
        let date = Date()
        let startOfDay = date.startOfDay
        let calendar = Calendar.current

        XCTAssertEqual(calendar.component(.hour, from: startOfDay), 0)
        XCTAssertEqual(calendar.component(.minute, from: startOfDay), 0)
        XCTAssertEqual(calendar.component(.second, from: startOfDay), 0)
    }

    func testIsToday() {
        let today = Date()
        XCTAssertTrue(today.isToday)

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        XCTAssertFalse(yesterday.isToday)
    }

    func testAddingDays() {
        let today = Date()
        let tomorrow = today.adding(days: 1)
        let calendar = Calendar.current

        let daysDiff = calendar.dateComponents([.day], from: today, to: tomorrow).day
        XCTAssertEqual(daysDiff, 1)
    }

    // MARK: - FormattedAmount Tests
    func testFormattedAmountMl() {
        let record = DrinkRecord(
            drinkTypeName: "ビール",
            drinkTypeEmoji: "🍺",
            amount: 350,
            alcoholPercentage: 5.0
        )
        XCTAssertEqual(record.formattedAmount, "350ml")
    }

    func testFormattedAmountLiter() {
        let record = DrinkRecord(
            drinkTypeName: "ビール",
            drinkTypeEmoji: "🍺",
            amount: 1500,
            alcoholPercentage: 5.0
        )
        XCTAssertEqual(record.formattedAmount, "1.5L")
    }
}
