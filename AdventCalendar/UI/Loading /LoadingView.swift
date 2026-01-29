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
        VStack(spacing: 24) {

            Text("Loading…")
                .font(.headline)

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
        .onAppear {
            withAnimation(.linear(duration: 1.6)) {
                progress = 220
            }
        }
    }
}

#Preview {
    LoadingView()
}
