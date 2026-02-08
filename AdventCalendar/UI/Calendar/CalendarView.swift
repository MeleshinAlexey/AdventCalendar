//
//  CalendarView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/20/26.
//

import SwiftUI

struct CalendarView: View {

    /// Selected topic passed from navigation.
    let topic: Topic

    @ObservedObject var router: HomeRouter

    private let progressStore = TaskProgressStore()

    @State private var completedDays: Set<Int> = []

    private func reloadCompletedDays() {
        completedDays = progressStore.loadCompletedDays(for: topic)
    }

    /// Unix timestamp (seconds) for the day the topic was created/selected.
    /// Day 1 door is available immediately on this date.
    @AppStorage("topic_start_date") private var topicStartDateRaw: Double = 0

    private let maxDay: Int = 30

    private var startDate: Date {
        // If not set yet, fall back to now to avoid crashes; UI will show 1 unlocked door.
        topicStartDateRaw > 0 ? Date(timeIntervalSince1970: topicStartDateRaw) : Date()
    }

    /// Doors 1...unlockedDayLimit are available today.
    private var unlockedDayLimit: Int {
        AdventProgress.unlockedCount(startDate: startDate)
    }

    private let calendarYellow = Color(red: 247/255, green: 208/255, blue: 83/255)

    private var headerAssetName: String {
        topic.calendarHeaderAssetName
    }

    private let columnsCount: CGFloat = 5
    private let columnSpacing: CGFloat = 10
    private let horizontalPadding: CGFloat = 18
    private let doorAspect: CGFloat = 78.0 / 64.0

    // Header sizing (adaptive)
    // Height is derived from available width to avoid side clipping / odd scaling on different devices.
    // Tune the multiplier if you want the header taller/shorter.
    private func headerHeight(for width: CGFloat) -> CGFloat {
        // Taller header; tuned to avoid looking too small on modern iPhones.
        let h = width * 0.70
        return min(420, max(280, h))
    }

    private func headerOverlap(for width: CGFloat) -> CGFloat {
        // Small overlap under the wave; scale a bit with width.
        min(16, max(8, width * 0.025))
    }

    private func gridHeight(for totalWidth: CGFloat) -> CGFloat {
        let totalSpacing = columnSpacing * (columnsCount - 1)
        let contentWidth = totalWidth - horizontalPadding * 2
        let cellWidth = (contentWidth - totalSpacing) / columnsCount
        let cellHeight = cellWidth * doorAspect

        let rows: CGFloat = 6
        let rowSpacing: CGFloat = 12
        return rows * cellHeight + (rows - 1) * rowSpacing + 10
    }

    private func safeGridHeight(for totalWidth: CGFloat) -> CGFloat {
        let h = gridHeight(for: totalWidth)
        // SwiftUI can do an initial layout pass with width == 0, which would make the computed height negative.
        // Clamp to a positive finite value to avoid runtime layout warnings.
        if !h.isFinite { return 1 }
        return max(1, h)
    }

    var body: some View {
        GeometryReader { rootGeo in
            let rootWidth = rootGeo.size.width
            let headerH = headerHeight(for: rootWidth)
            let overlap = headerOverlap(for: rootWidth)

            ScrollView {
                VStack(spacing: 0) {

                    // Header (scrolls together with content)
                    Image(headerAssetName)
                        .resizable()
                        .scaledToFill() // fill width => no white gaps on the sides
                        .frame(width: rootWidth, height: headerH, alignment: .top)
                        .clipped()
                        .clipShape(WaveBottomShape(amplitude: 30, baseline: 0.85))
                        .ignoresSafeArea(edges: [.top, .horizontal])

                    // Content (white)
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Calendar")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(calendarYellow)
                            .padding(.top, 10)

                        GeometryReader { geo in
                            let availableWidth = geo.size.width
                            let totalSpacing = columnSpacing * (columnsCount - 1)
                            let cellWidth = (availableWidth - totalSpacing) / columnsCount
                            let cellHeight = cellWidth * doorAspect

                            let columns: [GridItem] = Array(
                                repeating: GridItem(.fixed(cellWidth), spacing: columnSpacing),
                                count: Int(columnsCount)
                            )

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(1...maxDay, id: \.self) { day in
                                    DoorCell(
                                        day: day,
                                        isUnlocked: day <= unlockedDayLimit,
                                        isOpened: completedDays.contains(day),
                                        size: CGSize(width: cellWidth, height: cellHeight)
                                    ) {
                                        // Only unlocked doors can be opened (no lock)
                                        guard day <= unlockedDayLimit else { return }

                                        // Completed tasks can't be opened again
                                        guard !completedDays.contains(day) else { return }

                                        // Navigate to the card screen
                                        router.push(.cardOfDay(topic: topic, day: day))
                                    }
                                }
                            }
                            .padding(.top, 2)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .frame(height: safeGridHeight(for: rootWidth))

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 28)
                    .background(Color.white)
                    .offset(y: -overlap) // slight overlap under the wave
                }
            }
            .ignoresSafeArea(edges: [.top, .horizontal])
            // Prevent pulling the ScrollView down beyond the header (no top gap / no bounce)
            .onAppear {
                reloadCompletedDays()
                UIScrollView.appearance().bounces = false
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
            }
            .onChange(of: router.path) { _ in
                reloadCompletedDays()
            }
            .onDisappear {
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .automatic
                UIScrollView.appearance().bounces = true
            }
            .background(Color.white.ignoresSafeArea(edges: [.top, .horizontal]))
        }
    }
}

private struct DoorCell: View {

    let day: Int
    let isUnlocked: Bool
    let isOpened: Bool
    let size: CGSize
    let onTap: () -> Void

    var body: some View {
        ZStack {
            // Door image
            Image(isOpened ? "door_open" : "door_closed")
                .resizable()
                .scaledToFit()

            // Lock overlay only for locked days
            if !isUnlocked {
                let lockSize = min(size.width, size.height) * 0.45
                Image("lock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: lockSize, height: lockSize)
            }

            // Day number only when unlocked (even if door is still closed)
            if isUnlocked {
                let base = min(size.width, size.height)
                let outlineFont = base * 0.52
                let fillFont = base * 0.48

                ZStack {
                    // White outline (slightly bigger)
                    Text("\(day)")
                        .font(.system(size: outlineFont, weight: .heavy))
                        .foregroundStyle(.white)

                    // Yellow fill
                    Text("\(day)")
                        .font(.system(size: fillFont, weight: .heavy))
                        .foregroundStyle(Color(red: 247/255, green: 208/255, blue: 83/255))
                }
                .shadow(radius: 1)
                .offset(x: -base * 0.03, y: base * 0.03)
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
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

#Preview {
    // Preview seed: pretend calendar started 8 days ago.
    UserDefaults.standard.set(Date().addingTimeInterval(-8 * 24 * 60 * 60).timeIntervalSince1970, forKey: "topic_start_date")

    return NavigationStack {
        CalendarView(topic: .newYear, router: HomeRouter())
            .navigationTitle(Topic.newYear.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
