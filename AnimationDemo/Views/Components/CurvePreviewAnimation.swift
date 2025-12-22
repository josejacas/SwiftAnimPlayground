//
//  CurvePreviewAnimation.swift
//  AnimationDemo
//

import SwiftUI

struct CurvePreviewAnimation: View {
    let curve: CustomCurve
    let animationType: AnimationType
    let demoShape: DemoShape
    var isDragging: Bool = false
    var restartTrigger: Int = 0

    @State private var isAnimated = false
    @State private var timer: Timer?

    private let holdDuration: Double = 0.8

    var body: some View {
        // Animated shape
        animatedShape
            .frame(maxHeight: 250)
            .onAppear {
                startLoop()
            }
            .onDisappear {
                stopLoop()
            }
            .onChange(of: isDragging) { _, newValue in
                if newValue {
                    // Stop animation while dragging
                    stopLoop()
                    isAnimated = false
                } else {
                    // Restart when dragging ends
                    restartLoop()
                }
            }
            .onChange(of: restartTrigger) { _, _ in
                // Immediately restart when preset is selected
                stopLoop()
                isAnimated = false
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.05))
                    startLoop()
                }
            }
            .onChange(of: curve.duration) { _, _ in
                if !isDragging {
                    restartLoop()
                }
            }
            .onChange(of: animationType) { _, _ in
                restartLoop()
            }
    }

    @ViewBuilder
    private var animatedShape: some View {
        Group {
            switch demoShape {
            case .circle:
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 60, height: 60)
            case .roundedRect:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor)
                    .frame(width: 60, height: 60)
            }
        }
        .modifier(AnimationModifier(type: animationType, isAnimated: isAnimated))
    }

    // MARK: - Animation Loop

    private func startLoop() {
        triggerAnimation()

        let loopInterval = curve.duration + holdDuration + curve.duration + 0.3
        timer = Timer.scheduledTimer(withTimeInterval: loopInterval, repeats: true) { _ in
            triggerAnimation()
        }
    }

    private func stopLoop() {
        timer?.invalidate()
        timer = nil
    }

    private func restartLoop() {
        stopLoop()
        startLoop()
    }

    private func triggerAnimation() {
        let animation = curve.buildAnimation()

        withAnimation(animation) {
            isAnimated = true
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(curve.duration + holdDuration))
            withAnimation(animation) {
                isAnimated = false
            }
        }
    }
}

#Preview {
    CurvePreviewAnimation(
        curve: .easeInOut,
        animationType: .scale,
        demoShape: .roundedRect
    )
    .frame(width: 200)
    .padding()
}
