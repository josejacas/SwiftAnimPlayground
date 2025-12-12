//
//  HeartReactionExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct HeartReactionExampleView: View {
    @State private var isLiked = false
    @State private var heartScale: CGFloat = 1.0

    private let example = ExampleType.heartReaction

    var body: some View {
        ExampleCardContainer(example: example) {
            ZStack {
                // Tap area background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 200, height: 200)

                // Heart icon
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 100))
                    .foregroundStyle(isLiked ? .red : .gray)
                    .scaleEffect(heartScale)
            }
            .onTapGesture {
                triggerHeartAnimation()
            }
        }
    }

    private func triggerHeartAnimation() {
        isLiked.toggle()

        if isLiked {
            // Bounce up
            withAnimation(.spring(duration: 0.4, bounce: 0.6)) {
                heartScale = 1.3
            }

            // Return to normal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                    heartScale = 1.0
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                heartScale = 1.0
            }
        }
    }
}

#Preview {
    HeartReactionExampleView()
}
