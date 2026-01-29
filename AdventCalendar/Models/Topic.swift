//
//  Topic.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/21/26.
//

import Foundation

/// A selected theme/topic for the Advent calendar.
///
/// Stored in `@AppStorage("selected_topic")` using `rawValue`.
enum Topic: String, CaseIterable, Identifiable, Hashable {
    case newYear = "New Year"
    case winter = "Winter"
    case summer = "Summer"
    case fun = "Fun"
    case productivity = "Productivity"

    var id: String { rawValue }

    /// Title shown in UI.
    var title: String { rawValue }

    /// Asset name for the topic card in `ChoosingTopicView`.
    var assetName: String {
        switch self {
        case .newYear: return "topic_new_year"
        case .winter: return "topic_winter"
        case .summer: return "topic_summer"
        case .fun: return "topic_fun"
        case .productivity: return "topic_productivity"
        }
    }

    /// Asset name for the big header image in `CalendarView`.
    ///
    /// NOTE: If your asset names differ, adjust them here once.
    var calendarHeaderAssetName: String {
        switch self {
        case .newYear: return "calendar_header_new_year"
        case .winter: return "calendar_header_winter"
        case .summer: return "calendar_header_summer"
        case .fun: return "calendar_header_fun"
        case .productivity: return "calendar_header_productivity"
        }
    }
}
