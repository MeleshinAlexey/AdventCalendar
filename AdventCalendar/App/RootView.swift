//
//  RootView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/20/26.
//

import SwiftUI

struct RootView: View {

    // Router used only for the calendar creation flow (NO TabBar)
    @StateObject private var creationRouter = HomeRouter()

    // Routers for the main TabBar flows
    @StateObject private var homeRouter = HomeRouter()
    @StateObject private var statsRouter = HomeRouter()
    @StateObject private var archiveRouter = HomeRouter()

    // Calendar is considered "started" only if we have both a selected topic and a valid start date.
    @AppStorage("selected_topic") private var selectedTopicRawValue: String = ""
    @AppStorage("topic_start_date") private var topicStartDateRaw: Double = 0

    @Environment(\.scenePhase) private var scenePhase
     
    // MARK: - DEBUG Mocks
    @State private var didRunMockBootstrap: Bool = false
    @AppStorage("debug_use_mocks") private var debugUseMocks: Bool = false

    private func runMockBootstrapIfNeeded() {
        #if DEBUG
        // Run mock bootstrap ONLY when mocks are enabled.
        // Otherwise it can clear AppStorage right after the user creates a calendar.
        guard debugUseMocks else { return }
        guard !didRunMockBootstrap else { return }
        didRunMockBootstrap = true
        AppMockBootstrap.run()
        #endif
    }

    private var currentTopic: Topic? {
        let raw = selectedTopicRawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        return Topic(rawValue: raw)
    }

    private var currentDay: Int? {
        guard topicStartDateRaw > 0 else { return nil }
        let start = Date(timeIntervalSince1970: topicStartDateRaw)
        let unlocked = AdventProgress.unlockedCount(startDate: start, today: Date())
        // Clamp to 1...30 for safety
        return min(30, max(1, unlocked))
    }

    private var hasCreatedCalendar: Bool {
        currentTopic != nil && topicStartDateRaw > 0
    }

    private func presentSurveyIfNeeded() {
        // Only show Survey if a calendar has been started.
        guard let topic = currentTopic, let day = currentDay else { return }

        guard SurveyStore.shouldPresent(topic: topic, day: day) else { return }

        // Avoid pushing the same survey repeatedly.
        if homeRouter.path.last != .survey(topic: topic, day: day) {
            homeRouter.push(.survey(topic: topic, day: day))
        }
    }

    var body: some View {
        Group {
            if !hasCreatedCalendar {
                // ===== CREATION FLOW (NO TAB BAR) =====
                NavigationStack(path: $creationRouter.path) {
                    MainView(onChooseTheme: {
                        creationRouter.push(.choosingTopic)
                    })
                    .navigationDestination(for: HomeRoute.self) { route in
                        switch route {
                        case .choosingTopic:
                            ChoosingTopicView(router: creationRouter)
                                .navigationTitle("Choose theme")
                                .navigationBarTitleDisplayMode(.inline)
                        default:
                            EmptyView()
                        }
                    }
                }
            } else {
                // ===== MAIN APP (TAB BAR) =====
                TabView {

                    // ===== MAIN =====
                    NavigationStack(path: $homeRouter.path) {
                        Group {
                            if let topic = currentTopic {
                                CalendarView(topic: topic, router: homeRouter)
                                    .navigationBarTitleDisplayMode(.inline)
                            } else {
                                MainView(onChooseTheme: {
                                    homeRouter.push(.choosingTopic)
                                })
                            }
                        }
                        .navigationDestination(for: HomeRoute.self) { route in
                            switch route {
                            case .choosingTopic:
                                ChoosingTopicView(router: homeRouter)
                                    .navigationTitle("Choose theme")
                                    .navigationBarTitleDisplayMode(.inline)

                            case .calendar(let topic):
                                CalendarView(topic: topic, router: homeRouter)
                                    .navigationBarTitleDisplayMode(.inline)

                            case .cardOfDay(let topic, let day):
                                DayCardView(topic: topic, day: day, router: homeRouter)
                                    .navigationBarTitleDisplayMode(.inline)

                            case .survey(let topic, let day):
                                SurveyView(topic: topic, day: day, router: homeRouter)
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        }
                    }
                    .onAppear {
                        runMockBootstrapIfNeeded()
                        presentSurveyIfNeeded()
                    }
                    .onChange(of: scenePhase) { phase in
                        if phase == .active {
                            runMockBootstrapIfNeeded()
                            presentSurveyIfNeeded()
                        }
                    }
                    .tabItem {
                        Label {
                            Text("Main")
                        } icon: {
                            Image("tabbar_menu_gray")
                                .renderingMode(.template)
                        }
                    }

                    // ===== STATISTICS =====
                    NavigationStack(path: $statsRouter.path) {
                        StatisticsView(router: statsRouter)
                            .navigationDestination(for: HomeRoute.self) { route in
                                switch route {
                                case .choosingTopic:
                                    ChoosingTopicView(router: statsRouter)
                                        .navigationTitle("Choose theme")
                                        .navigationBarTitleDisplayMode(.inline)

                                case .calendar(let topic):
                                    CalendarView(topic: topic, router: statsRouter)
                                        .navigationBarTitleDisplayMode(.inline)

                                case .cardOfDay(let topic, let day):
                                    DayCardView(topic: topic, day: day, router: statsRouter)
                                        .navigationBarTitleDisplayMode(.inline)

                                case .survey(let topic, let day):
                                    SurveyView(topic: topic, day: day, router: statsRouter)
                                        .navigationBarTitleDisplayMode(.inline)
                                }
                            }
                            // The screen has its own header, so hide the navigation bar.
                            .toolbar(.hidden, for: .navigationBar)
                    }
                    .tabItem {
                        Label {
                            Text("Statistics")
                        } icon: {
                            Image("tabbar_statistics_gray")
                                .renderingMode(.template)
                        }
                    }

                    // ===== ARCHIVE =====
                    NavigationStack(path: $archiveRouter.path) {
                        ArchiveView(router: archiveRouter)
                            .navigationDestination(for: HomeRoute.self) { route in
                                switch route {
                                case .choosingTopic:
                                    ChoosingTopicView(router: archiveRouter)
                                        .navigationTitle("Choose theme")
                                        .navigationBarTitleDisplayMode(.inline)

                                case .calendar(let topic):
                                    CalendarView(topic: topic, router: archiveRouter)
                                        .navigationBarTitleDisplayMode(.inline)

                                case .cardOfDay(let topic, let day):
                                    DayCardView(topic: topic, day: day, router: archiveRouter)
                                        .navigationBarTitleDisplayMode(.inline)

                                case .survey(let topic, let day):
                                    SurveyView(topic: topic, day: day, router: archiveRouter)
                                        .navigationBarTitleDisplayMode(.inline)
                                }
                            }
                            // Archive screen has its own header, so hide the navigation bar.
                            .toolbar(.hidden, for: .navigationBar)
                    }
                    .tabItem {
                        Label {
                            Text("Archive")
                        } icon: {
                            Image("tabbar_atchive_gray")
                                .renderingMode(.template)
                        }
                    }
                }
            }
        }
        // Lock the entire app UI under RootView to a fixed appearance so it doesn't
        // track or react to system/user theme changes.
        .preferredColorScheme(.light)
        .environment(\.colorScheme, .light)
    }
}

#Preview {
    RootView()
}
