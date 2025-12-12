//
//  CardSwipeExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct CardSwipeExampleView: View {
    @State private var offset: CGSize = .zero
    @State private var cardColor: Color = .pink

    private let example = ExampleType.cardSwipe
    private let colors: [Color] = [.pink, .purple, .orange, .blue, .mint, .indigo]

    var body: some View {
        ExampleCardContainer(example: example) {
            GeometryReader { geometry in
                ZStack {
                    // Background cards (stacked effect)
                    ForEach(0..<2, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1 + Double(index) * 0.05))
                            .frame(width: 180, height: 260)
                            .offset(x: CGFloat(2 - index) * 6, y: CGFloat(2 - index) * 6)
                    }

                    // Main card
                    RoundedRectangle(cornerRadius: 16)
                        .fill(cardColor.gradient)
                        .frame(width: 180, height: 260)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 60))
                                Text("Swipe me!")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white.opacity(0.9))
                        )
                        .overlay(
                            // Like/Nope indicators
                            ZStack {
                                Text("LIKE")
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundStyle(.green)
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.green, lineWidth: 4)
                                    )
                                    .rotationEffect(.degrees(-20))
                                    .opacity(Double(offset.width) / 100.0)

                                Text("NOPE")
                                    .font(.system(size: 32, weight: .black))
                                    .foregroundStyle(.red)
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.red, lineWidth: 4)
                                    )
                                    .rotationEffect(.degrees(20))
                                    .opacity(Double(-offset.width) / 100.0)
                            }
                        )
                        .offset(x: offset.width, y: offset.height * 0.4)
                        .rotationEffect(.degrees(Double(offset.width) / 20.0))
                        .gesture(swipeGesture)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 100

                if abs(value.translation.width) > threshold {
                    // Swipe away
                    withAnimation(.spring(duration: 0.3)) {
                        offset = CGSize(
                            width: value.translation.width > 0 ? 500 : -500,
                            height: 0
                        )
                    }

                    // Reset after delay with new color
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        offset = .zero
                        cardColor = colors.randomElement() ?? .pink
                    }
                } else {
                    // Spring back
                    withAnimation(.spring(duration: 0.5, bounce: 0.25)) {
                        offset = .zero
                    }
                }
            }
    }
}

#Preview {
    CardSwipeExampleView()
}
