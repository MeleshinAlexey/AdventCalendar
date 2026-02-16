//
//  LoadingView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/29/26.
//

import SwiftUI

struct LoadingView: View {

    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {

                Text("Loading…")
                    .font(.headline)
                    .foregroundStyle(.black)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    Capsule()
                        .fill(Color.yellow)
                        .frame(
                            width: max(0, progress),
                            height: 12
                        )
                }
                .frame(width: 220)
            }
        }
        .preferredColorScheme(.light)
        .environment(\.colorScheme, .light)
        .onAppear {
            withAnimation(.linear(duration: 1.6)) {
                progress = 220
            }
        }
    }
}

#Preview {
    LoadingView()
        .preferredColorScheme(.light)
        .environment(\.colorScheme, .light)
}
