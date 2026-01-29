//
//  SurveyStore.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/24/26.
//

import Foundation

/// Handles persistence and presentation rules for the end-of-day Survey.
/// Rules:
/// - After 21:00, survey becomes pending for (topic, day)
/// - While pending, it must be shown
/// - After Send, it is marked as sent and never shown again for that day

enum SurveyStore {

    // MARK: - Keys

    private static func tidyTopic(_ topic: Topic) -> String {
        topic.rawValue.replacingOccurrences(of: " ", with: "_")
    }

    private static func pendingKey(topic: Topic, day: Int) -> String {
        "survey_pending_\(tidyTopic(topic))_\(day)"
    }

    private static func sentKey(topic: Topic, day: Int) -> String {
        "survey_sent_\(tidyTopic(topic))_\(day)"
    }

    private static func likedKey(topic: Topic, day: Int) -> String {
        "survey_liked_\(tidyTopic(topic))_\(day)"
    }

    private static func didEverythingKey(topic: Topic, day: Int) -> String {
        "survey_did_everything_\(tidyTopic(topic))_\(day)"
    }

    // MARK: - State

    static func isPending(topic: Topic, day: Int) -> Bool {
        UserDefaults.standard.bool(forKey: pendingKey(topic: topic, day: day))
    }

    static func isSent(topic: Topic, day: Int) -> Bool {
        UserDefaults.standard.bool(forKey: sentKey(topic: topic, day: day))
    }

    // MARK: - Transitions

    static func markPending(topic: Topic, day: Int) {
        UserDefaults.standard.set(true, forKey: pendingKey(topic: topic, day: day))
    }

    static func clearPending(topic: Topic, day: Int) {
        UserDefaults.standard.removeObject(forKey: pendingKey(topic: topic, day: day))
    }

    static func markSent(topic: Topic, day: Int, liked: Bool, didEverything: Bool) {
        UserDefaults.standard.set(liked, forKey: likedKey(topic: topic, day: day))
        UserDefaults.standard.set(didEverything, forKey: didEverythingKey(topic: topic, day: day))
        UserDefaults.standard.set(true, forKey: sentKey(topic: topic, day: day))
        clearPending(topic: topic, day: day)
    }

    // MARK: - Presentation rule

    /// Returns true if Survey must be shown now.
    /// - If already sent → false
    /// - If pending → true
    /// - If current time ≥ 21:00 → mark pending and return true
    static func shouldPresent(topic: Topic, day: Int, now: Date = Date()) -> Bool {
        guard (1...30).contains(day) else { return false }
        if isSent(topic: topic, day: day) { return false }
        if isPending(topic: topic, day: day) { return true }

        let hour = Calendar.current.component(.hour, from: now)
        if hour >= 21 {
            markPending(topic: topic, day: day)
            return true
        }
        return false
    }

    // MARK: - Aggregates (for Statistics)

    static func sentCount(topic: Topic) -> Int {
        (1...30).reduce(0) { acc, day in
            acc + (isSent(topic: topic, day: day) ? 1 : 0)
        }
    }

    static func likesCount(topic: Topic) -> Int {
        (1...30).reduce(0) { acc, day in
            guard isSent(topic: topic, day: day) else { return acc }
            let liked = UserDefaults.standard.bool(forKey: likedKey(topic: topic, day: day))
            return acc + (liked ? 1 : 0)
        }
    }

    static func dislikesCount(topic: Topic) -> Int {
        let sent = sentCount(topic: topic)
        let likes = likesCount(topic: topic)
        return max(0, sent - likes)
    }

    static func didEverythingCount(topic: Topic) -> Int {
        (1...30).reduce(0) { acc, day in
            guard isSent(topic: topic, day: day) else { return acc }
            let didEverything = UserDefaults.standard.bool(forKey: didEverythingKey(topic: topic, day: day))
            return acc + (didEverything ? 1 : 0)
        }
    }
    
    // MARK: - DEBUG seeding

    #if DEBUG
    /// Seeds survey answers for all days 1...30.
    /// Useful for testing Statistics/Archive with a fully completed calendar.
    static func seedPerfectSurvey(topic: Topic, liked: Bool = true, didEverything: Bool = true) {
        for day in 1...30 {
            UserDefaults.standard.set(liked, forKey: likedKey(topic: topic, day: day))
            UserDefaults.standard.set(didEverything, forKey: didEverythingKey(topic: topic, day: day))
            UserDefaults.standard.set(true, forKey: sentKey(topic: topic, day: day))
            UserDefaults.standard.removeObject(forKey: pendingKey(topic: topic, day: day))
        }
    }

    /// Seeds survey answers for days 1...days.
    /// Useful when all doors are unlocked but only some tasks are completed.
    static func seedSurvey(topic: Topic, days: Int, liked: Bool = true, didEverything: Bool = true) {
        let n = min(max(days, 0), 30)
        guard n > 0 else { return }

        for day in 1...n {
            UserDefaults.standard.set(liked, forKey: likedKey(topic: topic, day: day))
            UserDefaults.standard.set(didEverything, forKey: didEverythingKey(topic: topic, day: day))
            UserDefaults.standard.set(true, forKey: sentKey(topic: topic, day: day))
            UserDefaults.standard.removeObject(forKey: pendingKey(topic: topic, day: day))
        }
    }

    /// Clears all survey state for days 1...30.
    static func clearSurvey(topic: Topic) {
        for day in 1...30 {
            UserDefaults.standard.removeObject(forKey: pendingKey(topic: topic, day: day))
            UserDefaults.standard.removeObject(forKey: sentKey(topic: topic, day: day))
            UserDefaults.standard.removeObject(forKey: likedKey(topic: topic, day: day))
            UserDefaults.standard.removeObject(forKey: didEverythingKey(topic: topic, day: day))
        }
    }
    #endif
}
