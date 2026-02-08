//
//  FloatingTabSwitchMenu.swift
//  AdventCalendar
//
//  Created by ChatGPT on 2/7/26.
//

import SwiftUI
import Combine

enum AppTab: Hashable {
    case main
    case statistics
    case archive
}

final class TabSelectionModel: ObservableObject {
    @Published var selected: AppTab = .main

    init(selected: AppTab = .main) {
        self.selected = selected
    }
}

/// Compact floating menu to jump between tabs while tab bar is hidden.
struct FloatingTabSwitchMenu: View {

    @EnvironmentObject var tabSelection: TabSelectionModel
    let onMain: (() -> Void)?

    var body: some View {
        Menu {
            Button {
                onMain?()
                tabSelection.selected = .main
            } label: {
                Label("Main", systemImage: "house")
            }

            Button {
                tabSelection.selected = .statistics
            } label: {
                Label("Statistics", systemImage: "chart.bar.fill")
            }

            Button {
                tabSelection.selected = .archive
            } label: {
                Label("Archive", systemImage: "archivebox.fill")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(14)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(radius: 6, x: 0, y: 3)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 20)
        .accessibilityLabel("Quick tab switcher")
    }
}
