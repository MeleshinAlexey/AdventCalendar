//
//  AppMocks.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/28/26.
//

///  One-file mocks for previews + debug builds.
///  Drop this file into the project.
///
///  Usage examples are at the bottom.
///

import Foundation
import SwiftUI
import Combine

// MARK: - Mock switch (use in Debug/Previews)
// Tip: for the fastest workflow, set `AppMocking.enabledOverride` to true/false.
// Leave it as `nil` to control via the Debug UI toggle.

enum AppMocking {
    #if DEBUG
    /// Quick manual override (edit this one line when you want).
    /// Set to `true` to force mocks ON, `false` to force mocks OFF, or `nil` to use the UI toggle.
    static var enabledOverride: Bool? = nil

    /// Master switch for mocks.
    /// Priority:
    /// 1) `enabledOverride` (fast local toggle)
    /// 2) persisted UI toggle `debug_use_mocks`
    static var enabled: Bool {
        if let v = enabledOverride { return v }
        return UserDefaults.standard.bool(forKey: "debug_use_mocks")
    }
    #endif

    #if !DEBUG
    static let enabled: Bool = false
    #endif

    #if DEBUG
    /// When mocks are OFF, optionally clear previously seeded mock data once.
    static var clearDataWhenDisabled: Bool = true

    /// Force overwriting existing persisted data (use for one run when switching scenarios).
    static var forceOverride: Bool = false

    /// Pick what to seed.
    static var scenario: AppMockScenario = .allUnlockedPartial(
        topic: .newYear,
        daysPassed: 35,
        completedCount: 2,
        surveyDays: 20
    )
    #endif
}

// MARK: - Mock data (Topics / Dates / Cards)

enum AppMocks {

    // ---------- Topics ----------
    static let topics: [Topic] = [
        .newYear, .winter, .summer, .fun, .productivity
    ]

    static func defaultTopic() -> Topic { .newYear }

    // ---------- Dates ----------
    static func startDate(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    // ---------- Completed days ----------
    static func completedDays(topic: Topic) -> Set<Int> {
        // Customize per topic if needed
        switch topic {
        case .newYear:       return [1, 2, 3, 5, 7, 8, 10]
        case .winter:        return [1, 2, 4]
        case .summer:        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        case .fun:           return []
        case .productivity:  return [1, 2, 3, 4, 5, 6, 7, 8]
        }
    }

    // ---------- Survey answers ----------
    struct SurveyAnswer: Hashable {
        let topic: Topic
        let day: Int
        let liked: Bool
        let didEverything: Bool
    }

    static func surveyAnswers(topic: Topic) -> [SurveyAnswer] {
        // Example: pretend user sent surveys for some completed days.
        let done = Array(completedDays(topic: topic)).sorted()
        return done.prefix(8).enumerated().map { idx, day in
            SurveyAnswer(topic: topic, day: day, liked: idx % 3 != 0, didEverything: idx % 2 == 0)
        }
    }

    // ---------- Archive ----------
    struct ArchiveItem: Identifiable, Hashable {
        let id = UUID()
        let topic: Topic
        let startDate: Date
        let completedCount: Int
    }

    static func archive() -> [ArchiveItem] {
        [
            ArchiveItem(topic: .summer, startDate: startDate(daysAgo: 45), completedCount: 30),
            ArchiveItem(topic: .newYear, startDate: startDate(daysAgo: 20), completedCount: 18),
            ArchiveItem(topic: .winter, startDate: startDate(daysAgo: 80), completedCount: 30)
        ]
        .sorted { $0.startDate > $1.startDate }
    }
}

// MARK: - Persisted mock scenarios (UserDefaults/AppStorage seeding)

#if DEBUG

enum AppMockScenario: Hashable {
    /// All doors unlocked (daysPassed >= 30), but only part of tasks completed.
    case allUnlockedPartial(topic: Topic, daysPassed: Int, completedCount: Int, surveyDays: Int)

    /// Fully completed calendar (30/30) + survey for 30 days.
    case perfectFinished(topic: Topic, daysPassed: Int)

    var topic: Topic {
        switch self {
        case .allUnlockedPartial(let topic, _, _, _): return topic
        case .perfectFinished(let topic, _): return topic
        }
    }
}

enum AppMockBootstrap {

    private static let didClearKey = "__app_mocks_did_clear__"
    private static let didSeedKey = "__app_mocks_did_seed__"

    private static var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    /// Call this once on app start (and optionally when coming back to foreground).
    static func run() {
        if AppMocking.enabled {
            let didApply = applyScenario(AppMocking.scenario, forceOverride: AppMocking.forceOverride || isRunningForPreviews)
            if didApply {
                UserDefaults.standard.set(true, forKey: didSeedKey)
            }
            // One-shot override is handy; reset automatically.
            AppMocking.forceOverride = false
            // If mocks are on again, allow clearing next time they are turned off.
            UserDefaults.standard.set(false, forKey: didClearKey)
        } else if AppMocking.clearDataWhenDisabled {
            // Clear only if mocks previously seeded persisted data.
            guard UserDefaults.standard.bool(forKey: didSeedKey) else { return }
            clearAllMockDataOnce()
            // Once cleared, consider mock seeding removed.
            UserDefaults.standard.set(false, forKey: didSeedKey)
        }
    }

    private static func clearAllMockDataOnce() {
        if UserDefaults.standard.bool(forKey: didClearKey) { return }
        UserDefaults.standard.set(true, forKey: didClearKey)

        // Clear active calendar selection/start date.
        MockAppStorageSeed.clearActiveCalendar()
        UserDefaults.standard.set(false, forKey: "debug_use_mocks")

        // Clear per-topic progress/survey (safe even if keys don't exist).
        let progress = TaskProgressStore()
        for t in AppMocks.topics {
            progress.clearCompletion(topic: t)
            SurveyStore.clearSurvey(topic: t)
        }

        // Extra safety: wipe any persisted completion keys that may have been seeded by mocks.
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("completed_days_") {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private static func applyScenario(_ scenario: AppMockScenario, forceOverride: Bool) -> Bool {
        // If calendar already exists, do not override unless forced.
        if !forceOverride {
            let hasTopic = !(UserDefaults.standard.string(forKey: "selected_topic") ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
            let hasStart = UserDefaults.standard.double(forKey: "topic_start_date") > 0
            if hasTopic && hasStart { return false }
        }

        switch scenario {
        case .allUnlockedPartial(let topic, let daysPassed, let completedCount, let surveyDays):
            MockAppStorageSeed.setActiveCalendar(topic: topic, startDate: AppMocks.startDate(daysAgo: daysPassed))

            let progress = TaskProgressStore()
            progress.clearCompletion(topic: topic)
            progress.seedCompletion(topic: topic, completedCount: completedCount)

            SurveyStore.clearSurvey(topic: topic)
            SurveyStore.seedSurvey(topic: topic, days: surveyDays)
            return true

        case .perfectFinished(let topic, let daysPassed):
            MockAppStorageSeed.setActiveCalendar(topic: topic, startDate: AppMocks.startDate(daysAgo: daysPassed))

            let progress = TaskProgressStore()
            progress.clearCompletion(topic: topic)
            progress.seedPerfectCompletion(topic: topic)

            SurveyStore.clearSurvey(topic: topic)
            SurveyStore.seedPerfectSurvey(topic: topic)
            return true
        }
    }
}

#endif

// MARK: - In-memory stores (drop-in style)

/// In-memory replacement for TaskProgressStore behavior.
/// Use this in Previews or debug flows when you don’t want UserDefaults.
@MainActor
final class MockTaskProgressStore: ObservableObject {

    @Published private var completed: [Topic: Set<Int>] = [:]

    init(seed: Bool = true) {
        if seed {
            for t in AppMocks.topics {
                completed[t] = AppMocks.completedDays(topic: t)
            }
        }
    }

    func loadCompletedDays(for topic: Topic) -> Set<Int> {
        completed[topic] ?? []
    }

    func completedCount(for topic: Topic) -> Int {
        loadCompletedDays(for: topic).count
    }

    func isCompleted(topic: Topic, day: Int) -> Bool {
        loadCompletedDays(for: topic).contains(day)
    }

    func markCompleted(topic: Topic, day: Int) {
        guard (1...30).contains(day) else { return }
        var set = completed[topic] ?? []
        set.insert(day)
        completed[topic] = set
    }

    func clear(topic: Topic) {
        completed[topic] = []
    }
}

/// In-memory replacement for SurveyStore.
/// Stores sent+answers and supports aggregates.
@MainActor
final class MockSurveyStore: ObservableObject {

    struct Key: Hashable {
        let topic: Topic
        let day: Int
    }

    @Published private var pending: Set<Key> = []
    @Published private var sent: Set<Key> = []
    @Published private var liked: Set<Key> = []
    @Published private var didEverything: Set<Key> = []

    init(seed: Bool = true) {
        if seed {
            let t = AppMocks.defaultTopic()
            for a in AppMocks.surveyAnswers(topic: t) {
                let k = Key(topic: a.topic, day: a.day)
                sent.insert(k)
                if a.liked { liked.insert(k) }
                if a.didEverything { didEverything.insert(k) }
            }
        }
    }

    func isPending(topic: Topic, day: Int) -> Bool { pending.contains(.init(topic: topic, day: day)) }
    func isSent(topic: Topic, day: Int) -> Bool { sent.contains(.init(topic: topic, day: day)) }

    func markPending(topic: Topic, day: Int) { pending.insert(.init(topic: topic, day: day)) }
    func clearPending(topic: Topic, day: Int) { pending.remove(.init(topic: topic, day: day)) }

    func markSent(topic: Topic, day: Int, liked: Bool, didEverything: Bool) {
        let k = Key(topic: topic, day: day)
        sent.insert(k)
        pending.remove(k)
        if liked { self.liked.insert(k) } else { self.liked.remove(k) }
        if didEverything { self.didEverything.insert(k) } else { self.didEverything.remove(k) }
    }

    /// Same rule shape as your SurveyStore: after 21:00 -> pending
    func shouldPresent(topic: Topic, day: Int, now: Date = Date()) -> Bool {
        guard (1...30).contains(day) else { return false }
        if isSent(topic: topic, day: day) { return false }
        if isPending(topic: topic, day: day) { return true }
        let hour = Calendar.current.component(.hour, from: now)
        if hour >= 21 { markPending(topic: topic, day: day); return true }
        return false
    }

    // Aggregates
    func sentCount(topic: Topic) -> Int {
        sent.filter { $0.topic == topic }.count
    }

    func likesCount(topic: Topic) -> Int {
        liked.filter { $0.topic == topic && sent.contains($0) }.count
    }

    func dislikesCount(topic: Topic) -> Int {
        max(0, sentCount(topic: topic) - likesCount(topic: topic))
    }

    func didEverythingCount(topic: Topic) -> Int {
        didEverything.filter { $0.topic == topic && sent.contains($0) }.count
    }
}

// MARK: - Mock “AppState” (optional helper)

/// Small helper to seed AppStorage to simulate “calendar started”.
enum MockAppStorageSeed {

    static func setActiveCalendar(topic: Topic, startDate: Date) {
        UserDefaults.standard.set(topic.rawValue, forKey: "selected_topic")
        UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: "topic_start_date")
    }

    static func clearActiveCalendar() {
        UserDefaults.standard.set("", forKey: "selected_topic")
        UserDefaults.standard.set(0.0, forKey: "topic_start_date")
    }
}

// MARK: - Example usage (copy to Previews if you want)


//#Preview("Seed active calendar") {
//    MockAppStorageSeed.setActiveCalendar(topic: .newYear, startDate: AppMocks.startDate(daysAgo: 8))
//    return RootView()
//}

//#Preview("Mocks ON (override)") {
//    AppMocking.enabledOverride = true
//    AppMockBootstrap.run()
//    return RootView()
//}

#Preview("Mocks OFF (override)") {
    AppMocking.enabledOverride = false
    AppMockBootstrap.run()
    MockAppStorageSeed.clearActiveCalendar()
    return RootView()
}
