//
//  SurveyView.swift
//  AdventCalendar
//
//  Created by Alexey Meleshin on 1/24/26.
//

import SwiftUI

struct SurveyView: View {

    let topic: Topic
    let day: Int


    @ObservedObject var router: HomeRouter

    private let progressStore = TaskProgressStore()

    // MARK: - State

    /// nil = not selected yet
    @State private var liked: Bool? = nil
    /// nil = not selected yet
    @State private var didEverything: Bool? = nil

    @State private var didTapSend: Bool = false

    // MARK: - UI constants

    private let calendarYellow = Color(red: 247/255, green: 208/255, blue: 83/255)

    private func metrics(for size: CGSize) -> Metrics {
        Metrics(size: size)
    }

    private struct Metrics {
        let size: CGSize

        var width: CGFloat { size.width }
        var height: CGFloat { size.height }

        /// 0.75...1.0. Short screens get tighter vertical spacing.
        private var v: CGFloat {
            // ~780–820 is “comfortable” for modern iPhones in portrait.
            let k = height / 800
            return min(1.0, max(0.75, k))
        }

        var sidePadding: CGFloat { max(16, min(22, width * 0.05)) }
        var headerHeight: CGFloat { max(260, min(420, width * 0.70)) }
        var headerOverlap: CGFloat { max(10, min(16, width * 0.03)) }

        var questionFont: CGFloat { max(30, min(46, width * 0.105)) }

        var choiceButtonHeight: CGFloat { max(52, min(72, width * 0.16)) }
        var primaryButtonHeight: CGFloat { max(60, min(78, width * 0.18)) }

        // Vertical spacing (compressed by v on short screens)
        var blockTop1: CGFloat { (max(18, min(26, width * 0.06))) * v }
        var betweenTitleAndButtons: CGFloat { (max(18, min(26, width * 0.06))) * v }
        var betweenBlocks: CGFloat { (max(34, min(50, width * 0.11))) * v }
        var sendTop: CGFloat { (max(28, min(40, width * 0.085))) * v }
        var bottomSpacer: CGFloat { (max(12, min(22, width * 0.05))) * v }

        var headerTitleFont: CGFloat { max(24, min(30, width * 0.07)) }
    }

    private var canSend: Bool {
        liked != nil && didEverything != nil
    }

    private var headerAssetName: String {
        topic.calendarHeaderAssetName
    }

    var body: some View {
        GeometryReader { geo in
            let m = metrics(for: geo.size)
            let topInset = geo.safeAreaInsets.top

            ScrollView {
                VStack(spacing: 0) {

                    // Header
                    ZStack(alignment: .topLeading) {
                        Image(headerAssetName)
                            .resizable()
                            .scaledToFill()
                            // Extend the header under the status bar to eliminate any top gap
                            .frame(width: geo.size.width, height: m.headerHeight + topInset, alignment: .top)
                            .clipped()
                            .clipShape(WaveBottomShape(amplitude: 30, baseline: 0.85))
                            // Pull the header up so it starts at y=0
                            .offset(y: -topInset)

                        HStack(spacing: 0) {
                            Text("Survey")
                                .font(.system(size: m.headerTitleFont, weight: .heavy))
                                .foregroundStyle(.black)

                            Spacer()
                        }
                        .padding(.top, topInset + 12)
                        .padding(.horizontal, m.sidePadding)
                    }

                    // Content
                    VStack(spacing: 0) {

                        Text("Did you like it?")
                            .font(.system(size: m.questionFont, weight: .heavy))
                            .foregroundStyle(calendarYellow)
                            .multilineTextAlignment(.center)
                            .padding(.top, m.blockTop1)
                            .padding(.horizontal, m.sidePadding)

                        HStack(spacing: 18) {
                            SurveyAssetButton(
                                assetName: "dislike",
                                isSelected: liked == false,
                                height: m.choiceButtonHeight,
                                selectedBackgroundName: "button_red"
                            ) {
                                liked = false
                            }

                            SurveyAssetButton(
                                assetName: "like",
                                isSelected: liked == true,
                                height: m.choiceButtonHeight,
                                selectedBackgroundName: "button_green"
                            ) {
                                liked = true
                            }
                        }
                        .padding(.top, m.betweenTitleAndButtons)
                        .padding(.horizontal, m.sidePadding)

                        Text("Did you do\neverything?")
                            .font(.system(size: m.questionFont, weight: .heavy))
                            .foregroundStyle(calendarYellow)
                            .multilineTextAlignment(.center)
                            .padding(.top, m.betweenBlocks)
                            .padding(.horizontal, m.sidePadding)

                        HStack(spacing: 18) {
                            SurveyTextButton(
                                title: "No",
                                isSelected: didEverything == false,
                                height: m.choiceButtonHeight,
                                selectedBackgroundName: "button_red"
                            ) {
                                didEverything = false
                            }

                            SurveyTextButton(
                                title: "Yes!",
                                isSelected: didEverything == true,
                                height: m.choiceButtonHeight,
                                selectedBackgroundName: "button_green"
                            ) {
                                didEverything = true
                            }
                        }
                        .padding(.top, m.betweenTitleAndButtons)
                        .padding(.horizontal, m.sidePadding)

                        Button {
                            guard canSend else { return }
                            didTapSend = true

                            if let liked, let didEverything {
                                SurveyStore.markSent(topic: topic, day: day, liked: liked, didEverything: didEverything)
                            }

                            router.pop()
                        } label: {
                            ZStack {
                                Image(canSend ? "yellow_button" : "button_gray")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: m.primaryButtonHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                                Text("Send")
                                    .font(.system(size: 24, weight: .heavy))
                                    .foregroundStyle(Color.white)
                            }
                            .frame(maxWidth: .infinity)
                            .opacity(canSend ? 1.0 : 0.75)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSend)
                        .padding(.top, m.sendTop)
                        .padding(.horizontal, m.sidePadding)

                        Spacer(minLength: m.bottomSpacer)
                    }
                    .background(Color.white)
                    .offset(y: -m.headerOverlap)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(Color.white)
            .toolbar(.hidden, for: .navigationBar)
            .ignoresSafeArea(edges: .top)
            .background(ScrollViewConfigurator { scrollView in
                // Absolutely lock the top edge: no rubber-banding / no negative contentOffset.
                scrollView.bounces = false
                scrollView.alwaysBounceVertical = false
                scrollView.contentInsetAdjustmentBehavior = .never
                scrollView.contentInset = .zero
                scrollView.scrollIndicatorInsets = .zero
                if #available(iOS 15.0, *) {
                    scrollView.automaticallyAdjustsScrollIndicatorInsets = false
                }
            })
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled(!didTapSend)
        }
    }
}

// MARK: - Components

private struct SurveyAssetButton: View {

    let assetName: String
    let isSelected: Bool
    let height: CGFloat
    let selectedBackgroundName: String
    let action: () -> Void

    private var backgroundName: String {
        isSelected ? selectedBackgroundName : "button_gray"
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(backgroundName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: height * 0.55)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

private struct SurveyTextButton: View {

    let title: String
    let isSelected: Bool
    let height: CGFloat
    let selectedBackgroundName: String
    let action: () -> Void

    private var backgroundName: String {
        isSelected ? selectedBackgroundName : "button_gray"
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(backgroundName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text(title)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
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

// MARK: - UIKit bridge (disable bounce)

private struct ScrollViewConfigurator: UIViewRepresentable {
    let configure: (UIScrollView) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let scroll = findScrollView(near: uiView) {
                configure(scroll)
            }
        }
    }

    private func findScrollView(near view: UIView) -> UIScrollView? {
        // 1) Walk up the superview chain.
        var current: UIView? = view
        while let c = current {
            if let scroll = c as? UIScrollView { return scroll }
            current = c.superview
        }

        // 2) If that fails, search within the window (SwiftUI hosting hierarchies can be tricky).
        if let window = view.window {
            return findScrollView(in: window)
        }

        return nil
    }

    private func findScrollView(in root: UIView) -> UIScrollView? {
        if let scroll = root as? UIScrollView { return scroll }
        for sub in root.subviews {
            if let found = findScrollView(in: sub) { return found }
        }
        return nil
    }
}

#Preview {
    NavigationStack {
        SurveyView(topic: .newYear, day: 1, router: HomeRouter())
    }
}
