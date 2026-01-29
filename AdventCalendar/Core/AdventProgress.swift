//
//  AdventProgress.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/21/26.
//

import Foundation

/// Utility that calculates which Advent doors are available based on the topic start date.
///
/// Rules:
/// - Day 1 starts on the date the topic is created/selected.
/// - On day N (counting from the start day), doors 1...N are unlocked.
/// - Total is capped to 30 doors.
///
/// Storage keys:
/// - `topic_start_date` is stored as ISO8601 string.
enum AdventProgress {

    static let totalDoors: Int = 30

    // MARK: - Parsing / formatting

    static func makeISO8601Formatter() -> ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        // Use full date+time so it round-trips well.
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }

    /// Parses the stored start date.
    /// Returns nil if the string is empty or can't be parsed.
    static func parseStartDate(from isoString: String) -> Date? {
        let trimmed = isoString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Try with fractional seconds first (our preferred format)
        if let d = makeISO8601Formatter().date(from: trimmed) {
            return d
        }

        // Fallback for strings without fractional seconds
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        return fallback.date(from: trimmed)
    }

    /// Produces an ISO8601 string for storage.
    static func formatStartDate(_ date: Date) -> String {
        makeISO8601Formatter().string(from: date)
    }

    // MARK: - Core logic

    /// Calculates how many doors are unlocked for `today`, given the stored start date.
    ///
    /// If `startDate` is in the future, returns 1 (door #1 is considered available).
    static func unlockedCount(startDate: Date, today: Date = Date(), calendar: Calendar = .current) -> Int {
        let startDay = calendar.startOfDay(for: startDate)
        let todayDay = calendar.startOfDay(for: today)

        let daysPassed = calendar.dateComponents([.day], from: startDay, to: todayDay).day ?? 0
        // Door #1 on day 0, door #2 on day 1, etc.
        let raw = daysPassed + 1

        // Clamp 1...totalDoors
        return max(1, min(totalDoors, raw))
    }

    /// Returns whether a given door index (1-based) is unlocked.
    static func isDoorUnlocked(doorIndex: Int, startDate: Date, today: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard (1...totalDoors).contains(doorIndex) else { return false }
        return doorIndex <= unlockedCount(startDate: startDate, today: today, calendar: calendar)
    }

    /// Returns the number of days remaining until all doors are unlocked.
    static func daysRemaining(startDate: Date, today: Date = Date(), calendar: Calendar = .current) -> Int {
        let unlocked = unlockedCount(startDate: startDate, today: today, calendar: calendar)
        return max(0, totalDoors - unlocked)
    }
}
