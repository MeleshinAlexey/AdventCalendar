//
//  HomeRouter.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/20/26.
//

import Foundation

enum HomeRoute: Hashable {
    case choosingTopic
    case calendar(topic: Topic)
    case cardOfDay(topic: Topic, day: Int)
    case survey(topic: Topic, day: Int)
}
