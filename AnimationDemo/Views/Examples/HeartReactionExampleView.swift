//
//  HeartReactionExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct HeartReactionExampleView: View {
    @State private var isLiked = false
    @State private var heartScale: CGFloat = 1.0

    // Stage 1: Pop animation
    @State private var popAnimationType: AnimationTypeOption = .easeOut
    @State private var popParameters: [String: Double] = ["duration": 0.2]

    // Stage 2: Settle animation
    @State private var settleAnimationType: AnimationTypeOption = .spring
    @State private var settleParameters: [String: Double] = ["duration": 0.4, "bounce": 0.5]

    private let example = ExampleType.heartReaction

    private var simplifiedCode: String {
        let popCode = popAnimationType.codeString(with: popParameters)
        let settleCode = settleAnimationType.codeString(with: settleParameters)
        let popDuration = String(format: "%.2f", popParameters["duration"] ?? 0.25)
        return """
        import SwiftUI

        struct HeartButton: View {
            @State private var isLiked = false
            @State private var scale: CGFloat = 1.0

            var body: some View {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 32))
                    .foregroundStyle(isLiked ? .red : .gray)
                    .scaleEffect(scale)
                    .onTapGesture {
                        triggerAnimation()
                    }
            }

            func triggerAnimation() {
                isLiked.toggle()

                // Stage 1: Pop
                withAnimation(\(popCode)) {
                    scale = isLiked ? 1.3 : 0.8
                }

                // Stage 2: Settle back to normal
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(\(popDuration)))
                    withAnimation(\(settleCode)) {
                        scale = 1.0
                    }
                }
            }
        }

        #Preview {
            HeartButton()
        }
        """
    }

    var body: some View {
        VStack(spacing: 16) {
            // Title and description
            HStack(alignment: .top) {
                VStack(spacing: 6) {
                    Text(example.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(example.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ViewCodeButton(title: "\(example.rawValue) Example", code: simplifiedCode)
            }

            // Interactive animation area
            ZStack {
                // Tap area background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 200, height: 200)

                // Heart icon
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 100))
                    .foregroundStyle(isLiked ? .red : .gray)
                    .scaleEffect(heartScale)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(example.accentColor.opacity(0.05))
            )
            .clipped()
            .onTapGesture {
                triggerHeartAnimation()
            }

            // Two-stage animation code editors
            VStack(spacing: 12) {
                // Stage 1: Pop
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pop")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    InteractiveCodeEditor(
                        animationType: $popAnimationType,
                        parameters: $popParameters,
                        accentColor: .orange
                    )
                }

                // Stage 2: Settle
                VStack(alignment: .leading, spacing: 6) {
                    Text("Settle")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    InteractiveCodeEditor(
                        animationType: $settleAnimationType,
                        parameters: $settleParameters,
                        accentColor: .pink
                    )
                }
            }
        }
        .padding(24)
    }


    private func triggerHeartAnimation() {
        isLiked.toggle()

        let popDuration = popParameters["duration"] ?? 0.25

        // Stage 1: Pop (scale up or down)
        if isLiked {
            withAnimation(popAnimationType.buildAnimation(with: popParameters)) {
                heartScale = 1.4
            }
        } else {
            withAnimation(popAnimationType.buildAnimation(with: popParameters)) {
                heartScale = 0.6
            }
        }

        // Stage 2: Settle (return to normal)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(popDuration))
            withAnimation(settleAnimationType.buildAnimation(with: settleParameters)) {
                heartScale = 1.0
            }
        }
    }
}

#Preview {
    HeartReactionExampleView()
}
