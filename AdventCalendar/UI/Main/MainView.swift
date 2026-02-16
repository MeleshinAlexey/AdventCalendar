//
//  MainView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/20/26.
//

import SwiftUI

struct MainView: View {
    /// Call this when the user taps the main CTA button.
    let onChooseTheme: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                Spacer(minLength: 24)

                // Центровая картинка
                Image("main_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 260)
                    .padding(.top, 10)

                // Текст как на макете (в 2 строки)
                Text("You haven't chosen a theme for your\nAdvent calendar yet!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 6)

                // Кнопка на ассете yellow_button
                Button(action: onChooseTheme) {
                    ZStack {
                        Image("yellow_button")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(radius: 10, y: 6)

                        Text("Choose a theme")
                            .font(.headline)
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)

                Spacer(minLength: 32)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Main")
        .navigationBarTitleDisplayMode(.large)
        // Force light appearance for both content and navigation bar
        .preferredColorScheme(.light)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(Color.white)
    }
}

#Preview {
    NavigationStack {
        MainView(onChooseTheme: {})
    }
}
