//
//  DebugTimeView.swift
//  AdventCalendar
//
//  Debug panel (DEBUG-only in production wiring) to simulate day unlocking
//  by changing persisted storage: `topic_start_date` and per-topic progress keys.
//

import SwiftUI

struct DebugTimeView: View {

    // Global start date of the current topic cycle.
    // Calendar unlocking is based on: days since this date.
    @AppStorage("topic_start_date") private var topicStartDateISO: String = ""

    @State private var selectedDate: Date = Date()

    private let maxDay: Int = 30

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()

    private func parseStartDate() -> Date {
        AdventProgress.parseStartDate(from: topicStartDateISO) ?? Date()
    }

    private func setStartDate(_ date: Date) {
        topicStartDateISO = Self.iso.string(from: date)
        selectedDate = date
    }

    private func shiftStartDate(daysBack: Int) {
        // daysBack > 0 means: make start date earlier -> more days unlocked.
        let current = parseStartDate()
        if let shifted = Calendar.current.date(byAdding: .day, value: -daysBack, to: current) {
            setStartDate(shifted)
        }
    }

    private func shiftStartDateForward(days: Int) {
        // days > 0 means: make start date later -> fewer days unlocked.
        let current = parseStartDate()
        if let shifted = Calendar.current.date(byAdding: .day, value: days, to: current) {
            setStartDate(shifted)
        }
    }

    private func resetAllProgress() {
        // Clears completed/opened per-topic progress.
        // Keep the start date as-is (you can reset it separately).
        let defaults = UserDefaults.standard

        for topic in Topic.allCases {
            let tidy = topic.rawValue.replacingOccurrences(of: " ", with: "_")
            defaults.removeObject(forKey: "completed_days_\(tidy)")
            defaults.removeObject(forKey: "opened_days_\(tidy)")
        }
    }

    private func clearStartDate() {
        topicStartDateISO = ""
        selectedDate = Date()
    }

    private var unlockedNow: Int {
        AdventProgress.unlockedCount(startDate: parseStartDate(), today: Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Start date (topic_start_date)") {
                    DatePicker(
                        "Start date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )

                    Button("Apply start date") {
                        setStartDate(selectedDate)
                    }

                    Button("Set start date = today") {
                        setStartDate(Date())
                    }

                    Button(role: .destructive) {
                        clearStartDate()
                    } label: {
                        Text("Clear start date")
                    }
                }

                Section("Quick simulate (days passed)") {
                    // Moving start date BACK simulates that more days have passed.
                    Button("+1 day passed") { shiftStartDate(daysBack: 1) }
                    Button("+3 days passed") { shiftStartDate(daysBack: 3) }
                    Button("+7 days passed") { shiftStartDate(daysBack: 7) }
                    Button("+15 days passed") { shiftStartDate(daysBack: 15) }
                    Button("+30 days passed") { shiftStartDate(daysBack: 30) }

                    // Optional: undo if you went too far.
                    Button("-1 day passed") { shiftStartDateForward(days: 1) }
                }

                Section("Progress") {
                    HStack {
                        Text("Unlocked now")
                        Spacer()
                        Text("\(min(unlockedNow, maxDay))/\(maxDay)")
                            .foregroundStyle(.secondary)
                    }

                    Button(role: .destructive) {
                        resetAllProgress()
                    } label: {
                        Text("Reset ALL progress (completed/opened)")
                    }
                }

                Section("Current raw values") {
                    HStack {
                        Text("topic_start_date")
                        Spacer()
                        Text(topicStartDateISO.isEmpty ? "(empty)" : topicStartDateISO)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
            .navigationTitle("Debug")
        }
        .onAppear {
            selectedDate = parseStartDate()
        }
        .onChange(of: selectedDate) { _ in
            // No auto-apply: user taps Apply.
        }
    }
}

#Preview {
    DebugTimeView()
}
