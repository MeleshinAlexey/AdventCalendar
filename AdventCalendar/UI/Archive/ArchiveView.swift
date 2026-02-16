//
//  ArchiveView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/27/26.
//

import SwiftUI

fileprivate struct ArchiveEntry: Identifiable, Hashable {
    let id = UUID()
    let topic: Topic
    let completedDays: Int // 0...30
        let startDate: Date

        var totalDays: Int { AdventProgress.totalDoors }

        var endDate: Date {
            // End date = next day AFTER the 30th (last) door unlocks.
            // Door #1 unlocks on startDate, door #30 unlocks on startDate + 29 days,
            // so the calendar ends on startDate + 30 days.
            Calendar.current.date(byAdding: .day, value: totalDays, to: startDate) ?? startDate
        }

        /// Example: "Jan" / "Dec" / "Dec-Jan"
        var monthLabel: String {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "MMM"

            let cal = Calendar.current
            let startMonth = df.string(from: startDate)
            let endMonth = df.string(from: endDate)

            let sameMonth = cal.component(.month, from: startDate) == cal.component(.month, from: endDate)
            let sameYear = cal.component(.year, from: startDate) == cal.component(.year, from: endDate)

            if sameMonth && sameYear {
                return startMonth
            } else {
                return startMonth + "-" + endMonth
            }
        }

        /// Examples:
        /// - Same year (month shown above): "1–30, 2026"
        /// - Cross-month same year: "29–28, 2026"
        /// - Cross-year: "29, 2025–28, 2026"
        var rangeLabel: String {
            let cal = Calendar.current

            let startYear = cal.component(.year, from: startDate)
            let endYear = cal.component(.year, from: endDate)
            let startDay = cal.component(.day, from: startDate)
            let endDay = cal.component(.day, from: endDate)

            if startYear == endYear {
                return "\(startDay)–\(endDay), \(startYear)"
            } else {
                return "\(startDay), \(startYear)–\(endDay), \(endYear)"
            }
        }

        var isPerfect: Bool { completedDays >= AdventProgress.totalDoors }

    var statusAsset: String {
        isPerfect ? "archive_status_success" : "archive_status_failed"
    }

    var topicAsset: String {
        switch topic {
        case .newYear: return "archive_topic_new_year"
        case .winter: return "archive_topic_winter"
        case .summer: return "archive_topic_summer"
        case .fun: return "archive_topic_fun"
        case .productivity: return "archive_topic_productivity"
        }
    }

    var cardBaseColor: Color {
        switch topic {
        case .newYear: return Color.archiveNewYear
        case .winter: return Color.archiveWinter
        case .summer: return Color.archiveSummer
        case .fun: return Color.archiveFun
        case .productivity: return Color.archiveProductivity
        }
    }
}

struct ArchiveView: View {

    let router: HomeRouter

    @AppStorage("selected_topic") private var storedTopicRawValue: String = ""
    @AppStorage("topic_start_date") private var topicStartDateRaw: Double = 0

    private let progressStore = TaskProgressStore()

    // MARK: - Data

    private var activeTopic: Topic? {
        Topic(rawValue: storedTopicRawValue)
    }

    private var topicStartDate: Date? {
        topicStartDateRaw > 0 ? Date(timeIntervalSince1970: topicStartDateRaw) : nil
    }

    /// Archive = finished calendars.
    /// Currently we can only build history for the active calendar (we don't store per-topic start dates yet).
    private var archiveEntries: [ArchiveEntry] {
        guard let topic = activeTopic, let startDate = topicStartDate else { return [] }

        let completed = progressStore.completedCount(for: topic)
        let entry = ArchiveEntry(topic: topic, completedDays: completed, startDate: startDate)

        // Show in archive only after the calendar ended.
        return entry.endDate <= Date() ? [entry] : []
    }

    // MARK: - Metrics

    private func metrics(for size: CGSize) -> Metrics {
        Metrics(size: size)
    }

    @ViewBuilder
    private func archiveCard(_ entry: ArchiveEntry, m: Metrics) -> some View {
        ArchiveCardView(
            entry: entry,
            width: m.cardWidth,
            height: m.cardHeight,
            cornerRadius: m.cardCornerRadius,
            innerPadding: m.cardInnerPadding,
            topicTitleFont: m.topicTitleFont,
            monthFont: m.monthFont,
            rangeFont: m.rangeFont,
            statusSize: m.statusSize,
            topicIconSize: m.topicIconSize,
            shadowRadius: m.cardShadowRadius,
            shadowY: m.cardShadowY
        )
    }

    private struct Metrics {
        let size: CGSize

        var width: CGFloat { size.width }
        var height: CGFloat { size.height }

        /// The main adaptive scale source.
        var base: CGFloat { min(width, height) }

        /// Smooth vertical scaling based on available height.
        private var v: CGFloat {
            let k = height / max(height, 820) // 0..1
            // Keep enough spacing even on small screens.
            return max(0.78, min(1.0, k + 0.22))
        }

        var sidePadding: CGFloat { max(18, min(24, width * 0.06)) }
        var topPadding: CGFloat { max(22, min(34, width * 0.07)) }

        var titleFont: CGFloat { max(24, min(30, width * 0.075)) }
        var subtitleFont: CGFloat { max(26, min(32, width * 0.082)) }

        var betweenHeaderAndList: CGFloat { max(24, min(54, base * 0.085)) }

        // Card shadow (match StatisticsView)
        var cardShadowRadius: CGFloat { 8 }
        var cardShadowY: CGFloat { 4 }

        /// Visible gap between cards (match Statistics)
        var cardGap: CGFloat { 14 }

        var bottomPadding: CGFloat { max(24, min(50, base * 0.08)) }

        /// Extra space so the last card never goes under the TabBar.
        var tabBarSafeBottom: CGFloat { max(0, height * 0.12) }

        // MARK: - Adaptive card sizing (shared with Statistics)
        /// Target card width that stays consistent across tabs.
        /// Match Statistics: use full available width inside side paddings
        var cardWidth: CGFloat {
            width - (sidePadding * 2)
        }

        /// Card height derived from width so proportions stay stable.
        /// Slightly shorter than before to match the intended compact look.
        var cardHeight: CGFloat {
            max(112, min(140, cardWidth * 0.34))
        }

        var cardCornerRadius: CGFloat {
            max(20, min(24, cardWidth * 0.06))
        }

        var cardInnerPadding: CGFloat { 16 }

        var topicTitleFont: CGFloat { max(22, min(28, width * 0.07)) }
        var monthFont: CGFloat { max(18, min(22, width * 0.055)) }
        var rangeFont: CGFloat { max(34, min(44, width * 0.11)) }

        var statusSize: CGFloat { max(36, min(46, width * 0.115)) }
        var topicIconSize: CGFloat { max(88, min(132, width * 0.32)) }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let m = metrics(for: geo.size)
            let visibleArchive = archiveEntries
                .sorted { $0.startDate < $1.startDate }

            ZStack {
                // Non-scrolling screen background (prevents visual jumps between tabs)
                Color.white.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // Header
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Archive")
                                .font(.system(size: m.titleFont, weight: .bold, design: .default))
                                .foregroundStyle(Color.black.opacity(0.82))

                            Text("List of completed calendars")
                                .font(.system(size: m.subtitleFont, weight: .bold, design: .default))
                                .foregroundStyle(Color.archiveAccent)
                        }
                        // Match Statistics: safe-area top + adaptive spacing
                        .padding(.top, geo.safeAreaInsets.top + max(8, m.topPadding * 0.45))
                        .padding(.horizontal, m.sidePadding)

                        Spacer(minLength: m.betweenHeaderAndList)

                        // List (cards appear only after their calendar ended)
                        if visibleArchive.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("No completed calendars yet")
                                    .font(.system(size: max(18, min(22, m.titleFont * 0.8)), weight: .bold))
                                    .foregroundStyle(Color.black.opacity(0.70))

                                Text("Finish a calendar to see it here.")
                                    .font(.system(size: max(14, min(18, m.subtitleFont * 0.55)), weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.55))
                            }
                            .padding(.horizontal, m.sidePadding)
                        } else {
                            VStack(alignment: .center, spacing: m.cardGap) {
                                ForEach(visibleArchive) { entry in
                                    archiveCard(entry, m: m)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            router.push(.calendar(topic: entry.topic))
                                        }
                                }
                            }
                            .padding(.horizontal, m.sidePadding)
                        }

                        // Match Statistics: bake bottom safe area into content spacing
                        Spacer(minLength: max(m.bottomPadding, geo.safeAreaInsets.bottom + 12))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
    }
}

// MARK: - Card

private struct ArchiveCardView: View {

    fileprivate let entry: ArchiveEntry
    let width: CGFloat

    let height: CGFloat
    let cornerRadius: CGFloat
    let innerPadding: CGFloat

    let topicTitleFont: CGFloat
    let monthFont: CGFloat
    let rangeFont: CGFloat

    let statusSize: CGFloat
    let topicIconSize: CGFloat

    let shadowRadius: CGFloat
    let shadowY: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            entry.cardBaseColor.opacity(0.98),
                            entry.cardBaseColor.opacity(0.86)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            HStack(alignment: .center, spacing: 10) {

                // Left text block
                VStack(alignment: .leading, spacing: 6) {

                    // Title + status (same row) — keep the title fully visible (no ellipsis)
                    HStack(alignment: .center, spacing: 8) {
                        Text(entry.topic.title)
                            .font(.system(size: topicTitleFont, weight: .bold, design: .default))
                            .foregroundStyle(Color.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.25)
                            .allowsTightening(true)
                            .truncationMode(.tail)
                            .layoutPriority(1)

                        Image(entry.statusAsset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: statusSize, height: statusSize)
                            .accessibilityHidden(true)
                    }

                    Text(entry.monthLabel)
                        .font(.system(size: monthFont, weight: .bold, design: .default))
                        .foregroundStyle(Color.white.opacity(0.90))
                        .lineLimit(1)
                        .minimumScaleFactor(0.35)
                        .allowsTightening(true)
                        .truncationMode(.tail)

                    Text(entry.rangeLabel)
                        .font(.system(size: rangeFont, weight: .heavy, design: .default))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.30)
                        .allowsTightening(true)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 8)

                // Topic art
                let artSize = min(topicIconSize, height * 0.95)
                Image(entry.topicAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: artSize, height: artSize)
                    .accessibilityHidden(true)
            }
            .padding(innerPadding)
        }
        .frame(width: width)
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .shadow(radius: shadowRadius, y: shadowY)
    }
}

// MARK: - Colors

private extension Color {

    // Accent (same family as your app’s yellow headings)
    static let archiveAccent = Color(red: 248/255, green: 214/255, blue: 97/255)

    // Topic colors provided by design
    static let archiveNewYear = Color(red: 106/255, green: 64/255, blue: 245/255)
    static let archiveWinter = Color(red: 97/255, green: 171/255, blue: 248/255)
    static let archiveSummer = Color(red: 248/255, green: 210/255, blue: 86/255)
    static let archiveFun = Color(red: 198/255, green: 74/255, blue: 246/255)
    static let archiveProductivity = Color(red: 126/255, green: 251/255, blue: 96/255)
}

#Preview {
    ArchiveView(router: HomeRouter())
        .preferredColorScheme(.light)
        .environment(\.colorScheme, .light)
}
