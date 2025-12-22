//
//  CardFlipExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct CardFlipExampleView: View {
    @State private var isFlipped = false
    @State private var animationType: AnimationTypeOption = .bouncy
    @State private var parameters: [String: Double] = ["duration": 0.4, "extraBounce": 0.2]

    private let example = ExampleType.cardFlip

    private var simplifiedCode: String {
        let animCode = animationType.codeString(with: parameters)
        return """
        import SwiftUI

        struct FlippableCard: View {
            @State private var isFlipped = false

            var body: some View {
                ZStack {
                    // Front side
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.indigo.gradient)
                        .frame(width: 180, height: 240)
                        .overlay(
                            Image(systemName: "questionmark")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .opacity(isFlipped ? 0 : 1)
                        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

                    // Back side
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 180, height: 240)
                        .overlay(
                            VStack {
                                Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(.yellow)
                                Text("Surprise!").font(.headline)
                            }
                        )
                        .opacity(isFlipped ? 1 : 0)
                        .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                }
                .onTapGesture {
                    withAnimation(\(animCode)) {
                        isFlipped.toggle()
                    }
                }
            }
        }

        #Preview {
            FlippableCard()
        }
        """
    }

    var body: some View {
        ExampleCardContainer(
            example: example,
            animationType: $animationType,
            parameters: $parameters,
            fullCode: simplifiedCode
        ) {
            VStack {
                Spacer()

                // Flippable card
                ZStack {
                    // Front side
                    cardFront
                        .opacity(isFlipped ? 0 : 1)
                        .rotation3DEffect(
                            .degrees(isFlipped ? 180 : 0),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )

                    // Back side
                    cardBack
                        .opacity(isFlipped ? 1 : 0)
                        .rotation3DEffect(
                            .degrees(isFlipped ? 0 : -180),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                }
                .onTapGesture {
                    withAnimation(animationType.buildAnimation(with: parameters)) {
                        isFlipped.toggle()
                    }
                }

                Spacer()

                Text("Tap the card to flip")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)
            }
        }
    }

    private var cardFront: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark")
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(.white)

            Text("Tap to reveal")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(width: 200, height: 260)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [example.accentColor, example.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: example.accentColor.opacity(0.4), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var cardBack: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundStyle(.yellow)

            Text("Surprise!")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)

            Text("You found the secret")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(width: 200, height: 260)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    CardFlipExampleView()
}
