//
//  HomeRouter.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/20/26.
//

import SwiftUI
import Combine

final class HomeRouter: ObservableObject {
    @Published var path: [HomeRoute] = []

    func push(_ route: HomeRoute) {
        path.append(route)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
