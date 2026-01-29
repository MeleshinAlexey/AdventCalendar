//
//  ChoosingTopicView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/20/26.
//

import SwiftUI

struct ChoosingTopicView: View {

    @ObservedObject var router: HomeRouter

    /// Persist selected topic so Main screen can react later.
    @AppStorage("selected_topic") private var storedTopicRawValue: String = ""

    /// Start date stored as timeIntervalSince1970 (Double).
    /// Day 1 door is available immediately on this date.
    @AppStorage("topic_start_date") private var topicStartDateRaw: Double = 0

    @State private var selected: Topic? = nil

    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 16) {

            ScrollView {
                VStack(spacing: 16) {

                    // 2x2 grid
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        TopicCard(topic: .newYear, isSelected: selected == .newYear)
                            .onTapGesture { selected = .newYear }

                        TopicCard(topic: .winter, isSelected: selected == .winter)
                            .onTapGesture { selected = .winter }

                        TopicCard(topic: .summer, isSelected: selected == .summer)
                            .onTapGesture { selected = .summer }

                        TopicCard(topic: .fun, isSelected: selected == .fun)
                            .onTapGesture { selected = .fun }
                    }

                    // Full-width card
                    TopicCard(topic: .productivity, isSelected: selected == .productivity, isWide: true)
                        .onTapGesture { selected = .productivity }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            // Bottom CTA
            Button {
                guard let selected else { return }

                // Atomic write of active calendar
                let now = Date().timeIntervalSince1970
                storedTopicRawValue = selected.rawValue
                topicStartDateRaw = now

                router.push(.calendar(topic: selected))
            } label: {
                Text("Select")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        selected == nil
                        ? Color.gray.opacity(0.4)
                        : Color(red: 247/255, green: 208/255, blue: 83/255)
                    )
                    .foregroundStyle(.black.opacity(selected == nil ? 0.5 : 1))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .disabled(selected == nil)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle("Choosing a topic")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Ensure consistency: topic and start date must exist together
            let hasTopic = !storedTopicRawValue.isEmpty
            let hasStartDate = topicStartDateRaw > 0

            if hasTopic != hasStartDate {
                storedTopicRawValue = ""
                topicStartDateRaw = 0
                selected = nil
                return
            }

            if let t = Topic(rawValue: storedTopicRawValue), hasTopic {
                selected = t
            }
        }
    }
}

private struct TopicCard: View {

    let topic: Topic
    let isSelected: Bool
    var isWide: Bool = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            // Background image
            Image(topic.assetName)
                .resizable()
                .scaledToFill()
                .frame(height: isWide ? 160 : 210)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(radius: 10, y: 6)

            // Title (drawn by code, not inside the image)
            Text(topic.title)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .multilineTextAlignment(.leading)
                // Safe insets so text never touches the badge
                .padding(.leading, 16)
                .padding(.trailing, 64)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            Image(isSelected ? "topic_badge_selected" : "topic_badge_empty")
                .resizable()
                .frame(width: 44, height: 44)
                .padding(8)
                .offset(x: 4)
//                .offset(y: 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ChoosingTopicView(router: HomeRouter())
    }
}
