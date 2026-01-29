//
//  TaskProgressStore.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/23/26.
//

import Foundation
import SwiftUI

/// A tiny store responsible for:
/// - reading the topic start date from AppStorage
/// - computing which days are unlocked (1...N)
/// - persisting completed (done) days per topic
/// - helping DayCardView advance to the next available unlocked task on Skip
final class TaskProgressStore {

    // MARK: - Keys

    private func completedKey(for topic: Topic) -> String {
        "completed_days_\(topic.rawValue.replacingOccurrences(of: " ", with: "_"))"
    }

    // Shared key (same for all topics): start date of the current calendar cycle
    private let startDateKey = "topic_start_date"

    private let maxDay: Int = 30

    // MARK: - Start date

    private func loadStartDate() -> Date {
        let raw = UserDefaults.standard.double(forKey: startDateKey)
        return raw > 0 ? Date(timeIntervalSince1970: raw) : Date()
    }

    // MARK: - Unlocked

    func unlockedDayLimit(today: Date = Date()) -> Int {
        let n = AdventProgress.unlockedCount(startDate: loadStartDate(), today: today)
        return min(max(n, 1), maxDay)
    }

    func isDayUnlocked(_ day: Int, today: Date = Date()) -> Bool {
        (1...maxDay).contains(day) && day <= unlockedDayLimit(today: today)
    }

    // MARK: - Completed persistence

    func loadCompletedDays(for topic: Topic) -> Set<Int> {
        let raw = UserDefaults.standard.string(forKey: completedKey(for: topic)) ?? ""
        if raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        }

        let values = raw
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { (1...maxDay).contains($0) }

        return Set(values)
    }

    func isCompleted(topic: Topic, day: Int) -> Bool {
        loadCompletedDays(for: topic).contains(day)
    }

    func saveCompletedDays(_ days: Set<Int>, for topic: Topic) {
        let sorted = days
            .filter { (1...maxDay).contains($0) }
            .sorted()
            .map(String.init)
            .joined(separator: ",")

        UserDefaults.standard.set(sorted, forKey: completedKey(for: topic))
    }

    func markCompleted(topic: Topic, day: Int) {
        guard (1...maxDay).contains(day) else { return }
        var set = loadCompletedDays(for: topic)
        set.insert(day)
        saveCompletedDays(set, for: topic)
    }

    func completedCount(for topic: Topic) -> Int {
        loadCompletedDays(for: topic).count
    }

    // MARK: - Day selection helpers

    /// Returns the first available task day within [startDay...unlockedLimit] that is NOT completed.
    /// If the tapped day is locked, returns nil.
    func firstAvailableDay(topic: Topic, from tappedDay: Int, today: Date = Date()) -> Int? {
        let limit = unlockedDayLimit(today: today)
        guard tappedDay <= limit else { return nil }

        let completed = loadCompletedDays(for: topic)
        for d in max(1, tappedDay)...limit {
            if !completed.contains(d) { return d }
        }
        return nil
    }

    /// Returns the next available task day within [currentDay+1...unlockedLimit] that is NOT completed.
    func nextAvailableDay(topic: Topic, after currentDay: Int, today: Date = Date()) -> Int? {
        let limit = unlockedDayLimit(today: today)
        let start = currentDay + 1
        guard start <= limit else { return nil }

        let completed = loadCompletedDays(for: topic)
        for d in start...limit {
            if !completed.contains(d) { return d }
        }
        return nil
    }
    // MARK: - DEBUG seeding

    #if DEBUG
    /// Marks all days 1...30 as completed for the given topic.
    func seedPerfectCompletion(topic: Topic) {
        saveCompletedDays(Set(1...maxDay), for: topic)
    }

    /// Marks days 1...completedCount as completed for the given topic.
    func seedCompletion(topic: Topic, completedCount: Int) {
        let n = min(max(completedCount, 0), maxDay)
        if n == 0 {
            saveCompletedDays([], for: topic)
        } else {
            saveCompletedDays(Set(1...n), for: topic)
        }
    }

    /// Clears all completed days for the given topic.
    func clearCompletion(topic: Topic) {
        UserDefaults.standard.removeObject(forKey: completedKey(for: topic))
    }
    #endif
}
