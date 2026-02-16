//
//  StatisticsView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/27/26.
//

import SwiftUI

struct StatisticsView: View {

    let router: HomeRouter
    @AppStorage("selected_topic") private var storedTopicRawValue: String = ""
    @AppStorage("topic_start_date") private var topicStartDateRaw: Double = 0
    private let progressStore = TaskProgressStore()

    private var activeTopic: Topic? {
        Topic(rawValue: storedTopicRawValue)
    }

    private var hasActiveCalendar: Bool {
        activeTopic != nil && topicStartDateRaw > 0
    }

    private var topicStartDate: Date? {
        topicStartDateRaw > 0 ? Date(timeIntervalSince1970: topicStartDateRaw) : nil
    }

    private var completedDays: Int {
        guard let topic = activeTopic else { return 0 }
        return progressStore.completedCount(for: topic)
    }

    private var totalDays: Int { AdventProgress.totalDoors }

    private var likes: Int {
        guard let topic = activeTopic else { return 0 }
        return SurveyStore.likesCount(topic: topic)
    }

    private var dislikes: Int {
        guard let topic = activeTopic else { return 0 }
        return SurveyStore.dislikesCount(topic: topic)
    }

    /// Current overall completion in percent (Completed / 30).
    private var resultPercent: Int {
        guard totalDays > 0 else { return 0 }
        let ratio = Double(min(completedDays, totalDays)) / Double(totalDays)
        return Int((ratio * 100).rounded())
    }

    private var isFinished: Bool {
        completedDays >= totalDays
    }

    // MARK: - Metrics

    private func metrics(for size: CGSize) -> Metrics {
        Metrics(size: size)
    }

    private struct Metrics {
        let size: CGSize

        var width: CGFloat { size.width }
        var height: CGFloat { size.height }

        /// 0.75...1.0 — short screens get tighter vertical spacing.
        private var v: CGFloat {
            let k = height / 820
            return min(1.0, max(0.75, k))
        }

        var sidePadding: CGFloat { max(18, min(24, width * 0.06)) }
        var topPadding: CGFloat { max(22, min(34, width * 0.07)) }

        var titleFont: CGFloat { max(24, min(30, width * 0.075)) }
        var subtitleFont: CGFloat { max(26, min(32, width * 0.082)) }

        var betweenHeaderAndCards: CGFloat { (max(14, min(20, width * 0.05))) * v }
        var cardSpacing: CGFloat { (max(16, min(22, width * 0.05))) * v }
        var betweenCardsAndButton: CGFloat { (max(22, min(34, width * 0.075))) * v }
        var bottomPadding: CGFloat { (max(16, min(26, width * 0.06))) * v }

        // MARK: - Adaptive card sizing (shared with Archive)
        var cardWidth: CGFloat {
            let available = width - (sidePadding * 2)
            return min(380, max(320, available))
        }

        var cardHeight: CGFloat {
            max(124, min(156, cardWidth * 0.40))
        }

        var cardCornerRadius: CGFloat {
            max(20, min(24, cardWidth * 0.06))
        }

        var cardInnerPadding: CGFloat { max(18, min(22, width * 0.055)) }

        var cardTitleFont: CGFloat { max(18, min(21, width * 0.052)) }
        var cardValueFont: CGFloat { max(32, min(40, width * 0.10)) }

        var iconSize: CGFloat { max(68, min(92, width * 0.22)) }

        var buttonHeight: CGFloat { max(56, min(68, width * 0.155)) }
        var buttonCornerRadius: CGFloat { max(22, min(28, width * 0.07)) }
        var buttonFont: CGFloat { max(18, min(21, width * 0.052)) }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let m = metrics(for: geo.size)

            ScrollView {
                if !hasActiveCalendar {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Statistics")
                            .font(.system(size: m.titleFont, weight: .bold, design: .default))
                            .foregroundStyle(Color.black.opacity(0.82))

                        Text("No active calendar")
                            .font(.system(size: m.subtitleFont, weight: .bold, design: .default))
                            .foregroundStyle(Color.statsYellowText)

                        Text("Start a calendar to see your stats.")
                            .font(.system(size: max(16, min(18, m.subtitleFont * 0.55)), weight: .semibold, design: .default))
                            .foregroundStyle(Color.black.opacity(0.62))
                            .padding(.top, 2)
                    }
                    .padding(.top, m.topPadding)
                    .padding(.horizontal, m.sidePadding)

                    Spacer(minLength: m.betweenHeaderAndCards)

                    Button {
                        router.push(.choosingTopic)
                    } label: {
                        Text("Start a calendar")
                            .font(.system(size: m.buttonFont, weight: .bold, design: .default))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: m.buttonHeight)
                            .background(
                                RoundedRectangle(cornerRadius: m.buttonCornerRadius, style: .continuous)
                                    .fill(Color.statsButtonYellow)
                            )
                            .shadow(radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, m.sidePadding)
                    .padding(.top, m.betweenCardsAndButton * 0.35)

                    Spacer(minLength: m.bottomPadding)
                } else {
                    VStack(alignment: .leading, spacing: 0) {

                        // Header
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Statistics")
                                .font(.system(size: m.titleFont, weight: .bold, design: .default))
                                .foregroundStyle(Color.black.opacity(0.82))

                            Text("Results of the last Advent:")
                                .font(.system(size: m.subtitleFont, weight: .bold, design: .default))
                                .foregroundStyle(Color.statsYellowText)
                        }
                        .padding(.top, m.topPadding)
                        .padding(.horizontal, m.sidePadding)

                        Spacer(minLength: m.betweenHeaderAndCards)

                        // Cards
                        VStack(spacing: m.cardSpacing) {
                            StatisticsCardView(
                                title: "Completed:",
                                value: "\(min(completedDays, totalDays))/\(totalDays)",
                                iconAsset: "stats_icon_completed",
                                gradient: LinearGradient(
                                    gradient: Gradient(colors: [Color.statsBlueTop, Color.statsBlueBottom]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                width: m.cardWidth,
                                height: m.cardHeight,
                                cornerRadius: m.cardCornerRadius,
                                innerPadding: m.cardInnerPadding,
                                titleFont: m.cardTitleFont,
                                valueFont: m.cardValueFont,
                                iconSize: m.iconSize
                            )

                            StatisticsCardView(
                                title: "Likes/Dislikes:",
                                value: "\(likes)/\(dislikes)",
                                iconAsset: "stats_icon_likes",
                                gradient: LinearGradient(
                                    gradient: Gradient(colors: [Color.statsPurpleTop, Color.statsPurpleBottom]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                width: m.cardWidth,
                                height: m.cardHeight,
                                cornerRadius: m.cardCornerRadius,
                                innerPadding: m.cardInnerPadding,
                                titleFont: m.cardTitleFont,
                                valueFont: m.cardValueFont,
                                iconSize: m.iconSize
                            )

                            StatisticsCardView(
                                title: "Result:",
                                value: "\(resultPercent)%",
                                iconAsset: "stats_icon_result",
                                gradient: LinearGradient(
                                    gradient: Gradient(colors: [Color.statsYellowTop, Color.statsYellowBottom]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                width: m.cardWidth,
                                height: m.cardHeight,
                                cornerRadius: m.cardCornerRadius,
                                innerPadding: m.cardInnerPadding,
                                titleFont: m.cardTitleFont,
                                valueFont: m.cardValueFont,
                                iconSize: m.iconSize
                            )
                        }
                        .padding(.horizontal, m.sidePadding)

                        Spacer(minLength: m.betweenCardsAndButton)

                        if !isFinished {
                            // Reserve a bit of space so the layout doesn't look "cut off" without the button.
                            Spacer(minLength: m.buttonHeight * 0.35)
                        }

                        // Primary button (appears only after Day 30)
                        if isFinished {
                            Button {
                                // TODO: start a new Advent (reset progress + go to topic chooser)
                                // For now we only clear the start date flag.
                                topicStartDateRaw = 0
                            } label: {
                                Text("Start a new one")
                                    .font(.system(size: m.buttonFont, weight: .bold, design: .default))
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: m.buttonHeight)
                                    .background(
                                        RoundedRectangle(cornerRadius: m.buttonCornerRadius, style: .continuous)
                                            .fill(Color.statsButtonYellow)
                                    )
                                    .shadow(radius: 8, y: 4)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, m.sidePadding)
                        }

                        Spacer(minLength: m.bottomPadding)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .safeAreaInset(edge: .top) {
                // Keeps the header below the Dynamic Island / notch.
                Color.clear
                    .frame(height: geo.safeAreaInsets.top)
            }
            .background(Color.white.ignoresSafeArea())
            .scrollBounceBehavior(.basedOnSize)
        }
        .preferredColorScheme(.light)
        .environment(\.colorScheme, .light)
    }
}

// MARK: - Card

private struct StatisticsCardView: View {
    let title: String
    let value: String
    let iconAsset: String
    let gradient: LinearGradient

    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let innerPadding: CGFloat

    let titleFont: CGFloat
    let valueFont: CGFloat
    let iconSize: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(gradient)
                .shadow(radius: 8, y: 4)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.system(size: titleFont, weight: .bold, design: .default))
                        .foregroundStyle(Color.white.opacity(0.92))

                    Text(value)
                        .font(.system(size: valueFont, weight: .heavy, design: .default))
                        .foregroundStyle(Color.white)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                }

                Spacer(minLength: 10)

                Image(iconAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .accessibilityHidden(true)
            }
            .padding(innerPadding)
        }
        .frame(width: width)
        .frame(height: height)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Colors

private extension Color {

    // Base colors provided by design
    static let statsBlueBase = Color(red: 95/255, green: 166/255, blue: 248/255)
    static let statsPurpleBase = Color(red: 195/255, green: 69/255, blue: 246/255)
    static let statsYellowBase = Color(red: 248/255, green: 214/255, blue: 97/255)

    // Subtle gradients (top -> bottom)
    static let statsBlueTop = statsBlueBase.opacity(0.98)
    static let statsBlueBottom = statsBlueBase.opacity(0.86)

    static let statsPurpleTop = statsPurpleBase.opacity(0.98)
    static let statsPurpleBottom = statsPurpleBase.opacity(0.86)

    static let statsYellowTop = statsYellowBase.opacity(0.98)
    static let statsYellowBottom = statsYellowBase.opacity(0.88)

    // Text / button
    static let statsYellowText = statsYellowBase
    static let statsButtonYellow = statsYellowBase
}

#Preview {
    NavigationStack {
        StatisticsView(router: HomeRouter())
    }
    .preferredColorScheme(.light)
    .environment(\.colorScheme, .light)
}
