//
//  DayCardView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/21/26.
//

import SwiftUI

struct DayCardView: View {

    let topic: Topic
    let day: Int

    init(topic: Topic, day: Int, router: HomeRouter) {
        self.topic = topic
        self.day = day
        self.router = router
        _shownDay = State(initialValue: day)
    }

    // Header sizing (match CalendarView style)
    private func headerHeight(for width: CGFloat) -> CGFloat {
        // CalendarView uses width-based header sizing. Here we use 0.70 (per your latest choice).
        let h = width * 0.70
        return min(420, max(280, h))
    }

    private func headerOverlap(for width: CGFloat) -> CGFloat {
        min(16, max(8, width * 0.025))
    }

    @ObservedObject var router: HomeRouter

    private let progressStore = TaskProgressStore()

    @AppStorage("topic_start_date") private var topicStartDateRaw: Double = 0

    private var startDate: Date {
        topicStartDateRaw > 0 ? Date(timeIntervalSince1970: topicStartDateRaw) : Date()
    }

    private var unlockedDayLimit: Int {
        AdventProgress.unlockedCount(startDate: startDate)
    }

    private func nextUnlockedUncompletedDay(after day: Int) -> Int? {
        let completed = progressStore.loadCompletedDays(for: topic)
        let start = max(1, min(day + 1, 30))
        let end = min(unlockedDayLimit, 30)
        guard start <= end else { return nil }

        for d in start...end {
            if !completed.contains(d) { return d }
        }
        return nil
    }

    private func firstUnlockedUncompletedDay(from day: Int) -> Int? {
        let completed = progressStore.loadCompletedDays(for: topic)
        let start = max(1, min(day, 30))
        let end = min(unlockedDayLimit, 30)
        guard start <= end else { return nil }

        for d in start...end {
            if !completed.contains(d) { return d }
        }
        return nil
    }

    @State private var shownDay: Int
    @State private var showNoMoreTasksMessage: Bool = false

    private var wreathAssetName: String {
        switch topic {
        case .newYear: return "wreath_new_year"
        case .winter: return "wreath_winter"
        case .summer: return "wreath_summer"
        case .fun: return "wreath_fun"
        case .productivity: return "wreath_productivity"
        }
    }

    private var taskText: String {
        DayTasks.task(topic: topic, day: shownDay).text
    }

    private var isShownDayCompleted: Bool {
        progressStore.isCompleted(topic: topic, day: shownDay)
    }

    var body: some View {
        GeometryReader { geo in
            // Layout constants
            let sidePadding: CGFloat = 18
            let buttonSpacing: CGFloat = 16
            let buttonHeight: CGFloat = 72
            let buttonsBlockHeight: CGFloat = buttonHeight + 12 + 16 // height + top + bottom padding

            // Full-bleed width (includes horizontal safe areas)
            let fullWidth = geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing
            let headerH = headerHeight(for: fullWidth)
            let overlap = headerOverlap(for: fullWidth)

            // Space left for the wreath/content
            let remainingH = max(0, geo.size.height - headerH - overlap - buttonsBlockHeight)

            // Wreath sizing
            // Primary driver is WIDTH (so the wreath keeps its visual weight).
            // Height only acts as a soft limit, not the main constraint.
            let wreathMaxW = max(0, geo.size.width - sidePadding * 2)

            // Desired size based on width (near "real" size)
            let desiredWreathSize = wreathMaxW * 0.9

            // Soft vertical cap: allow the wreath to slightly overlap the header/content logic
            // instead of shrinking too aggressively.
            let verticalCap = remainingH + overlap * 0.6

            let wreathSize = max(
                220,
                min(desiredWreathSize, verticalCap)
            )

            // Inner debug box (text container) scales with wreath
            let innerBox = max(200, wreathSize * 0.70)

            VStack(spacing: 0) {

                // ===== HEADER (fixed, no gap) =====
                ZStack(alignment: .topLeading) {
                    Image(topic.calendarHeaderAssetName)
                        .resizable()
                        .scaledToFill()
                        // Use fullWidth and shift left so the image extends under the safe areas.
                        .frame(width: fullWidth, height: headerH)
                        .offset(x: -geo.safeAreaInsets.leading)
                        .clipped()
                        .clipShape(WaveBottomShape(amplitude: 30, baseline: 0.85))
                        .ignoresSafeArea(edges: [.top, .horizontal])

                    HStack(spacing: 12) {
                        Button {
                            router.pop()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.45))
                                    .frame(width: 40, height: 40)

                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)

                        Text("Card of the day")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: 2)

                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                }

                // ===== CONTENT =====
                VStack(spacing: 0) {
                    ZStack {
                        Image(wreathAssetName)
                            .resizable()
                            // Many wreath PNGs have transparent padding. Fill + clip effectively "zooms"
                            // the visible wreath without changing the layout box.
                            .scaledToFill()
                            .frame(width: wreathSize, height: wreathSize)
                            .clipped()
                            .scaleEffect(1.15)

                        VStack(spacing: 10) {
                            Text("\(shownDay) DAY")
                                .font(.system(size: max(30, innerBox * 0.17), weight: .heavy))
                                .foregroundStyle(Color(red: 247/255, green: 208/255, blue: 83/255))

                            Text("Task:")
                                .font(.system(size: max(18, innerBox * 0.10), weight: .bold))
                                .foregroundStyle(.black)

                            Text(taskText)
                                .font(.system(size: max(16, innerBox * 0.095), weight: .bold))
                                .foregroundStyle(Color.blue)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                                .lineLimit(3)
                                .minimumScaleFactor(0.75)

                            if showNoMoreTasksMessage {
                                Text("No more open tasks. Come back tomorrow.")
                                    .font(.system(size: max(14, innerBox * 0.07), weight: .semibold))
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 6)
                            }
                        }
                        .frame(width: innerBox, height: innerBox, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .offset(y: -overlap)

                // ===== BOTTOM BUTTONS (adaptive, safe) =====
                let availableButtonsW = geo.size.width - sidePadding * 2 - buttonSpacing
                let buttonW = max(0, availableButtonsW / 2)

                // If there is no next available day, Skip should be disabled (instead of showing a message)
                let nextSkipDay = nextUnlockedUncompletedDay(after: shownDay)
                let isSkipDisabled = (shownDay >= 30) || (nextSkipDay == nil)

                HStack(spacing: buttonSpacing) {
                    Button {
                        // Advance to the next unlocked, not-yet-completed task day.
                        guard !isSkipDisabled else { return }
                        if let next = nextSkipDay {
                            shownDay = next
                            showNoMoreTasksMessage = false
                        }
                    } label: {
                        ZStack {
                            Image("button_red")
                                .resizable()
                                .scaledToFill()
                                .frame(width: buttonW, height: buttonHeight)
                                .clipped()
                                .opacity(isSkipDisabled ? 0.55 : 1.0)

                            Text("Skip")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                                .opacity(isSkipDisabled ? 0.85 : 1.0)
                        }
                        .frame(width: buttonW, height: buttonHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(isSkipDisabled)

                    Button {
                        // Anti-farm: a day can be completed only once.
                        guard !isShownDayCompleted else { return }

                        progressStore.markCompleted(topic: topic, day: shownDay)

                        // Show Survey only when required by rules (after 21:00 or if already pending).
                        if SurveyStore.shouldPresent(topic: topic, day: shownDay) {
                            router.pop()
                            DispatchQueue.main.async {
                                router.push(.survey(topic: topic, day: shownDay))
                            }
                        } else {
                            router.pop()
                        }
                    } label: {
                        ZStack {
                            Image("button_green")
                                .resizable()
                                .scaledToFill()
                                .frame(width: buttonW, height: buttonHeight)
                                .clipped()
                                .opacity(isShownDayCompleted ? 0.55 : 1.0)

                            Text(isShownDayCompleted ? "Done" : "Done")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                                .opacity(isShownDayCompleted ? 0.85 : 1.0)
                        }
                        .frame(width: buttonW, height: buttonHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(isShownDayCompleted)
                }
                .padding(.horizontal, sidePadding)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(Color.white)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Color.white.ignoresSafeArea())
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.light)
        .environment(\.colorScheme, .light)
        .onAppear {
            if let first = firstUnlockedUncompletedDay(from: day) {
                shownDay = first
                showNoMoreTasksMessage = false
            } else {
                // If tapped day is locked or everything is completed, show message.
                showNoMoreTasksMessage = true
                shownDay = day
            }
        }
    }
}

#Preview {
    NavigationStack {
        DayCardView(topic: .newYear, day: 1, router: HomeRouter())
    }
    .preferredColorScheme(.light)
    .environment(\.colorScheme, .light)
}

/// Wave shape for the bottom edge of the header image
private struct WaveBottomShape: Shape {
    var amplitude: CGFloat
    /// 0...1, where the wave sits vertically in the rect
    var baseline: CGFloat

    func path(in rect: CGRect) -> Path {
        let y = rect.height * baseline
        let w = rect.width

        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: y))

        // Smooth wave back to the left
        p.addCurve(
            to: CGPoint(x: 0, y: y),
            control1: CGPoint(x: w * 0.66, y: y + amplitude),
            control2: CGPoint(x: w * 0.33, y: y - amplitude)
        )

        p.closeSubpath()
        return p
    }
}
