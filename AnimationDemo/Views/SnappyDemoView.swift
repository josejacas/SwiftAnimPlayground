//
//  SnappyDemoView.swift
//  AnimationDemo
//

import SwiftUI
import AppKit

struct SnappyDemoView: View {
    let title: String
    let initialExtraBounce: Double
    let duration: Double
    let holdDuration: Double
    let animationType: AnimationType
    let shape: DemoShape

    @State private var extraBounce: Double
    @State private var isAnimated = false
    @State private var timer: Timer?
    @State private var showCopied = false

    init(title: String, initialExtraBounce: Double, duration: Double, holdDuration: Double, animationType: AnimationType, shape: DemoShape) {
        self.title = title
        self.initialExtraBounce = initialExtraBounce
        self.duration = duration
        self.holdDuration = holdDuration
        self.animationType = animationType
        self.shape = shape
        _extraBounce = State(initialValue: initialExtraBounce)
    }

    private var animation: Animation {
        .snappy(duration: duration, extraBounce: extraBounce)
    }

    private var loopInterval: Double {
        duration + holdDuration + duration + 0.3
    }

    private var codeString: String {
        "\(title)(duration: \(String(format: "%.1f", duration)), extraBounce: \(String(format: "%.1f", extraBounce)))"
    }

    var body: some View {
        VStack(spacing: 12) {
            animationArea
            titleLabel
            extraBounceSlider
            codePreview
        }
        .padding()
        .frame(width: 220, height: 280)
        .background(cardBackground)
        .onAppear { startLoop() }
        .onDisappear { timer?.invalidate() }
        .onChange(of: duration) { restartLoop() }
        .onChange(of: holdDuration) { restartLoop() }
        .onChange(of: animationType) { restartLoop() }
    }

    // MARK: - View Components

    private var animationArea: some View {
        ZStack {
            DemoShapeView(shape: shape)
                .modifier(AnimationModifier(type: animationType, isAnimated: isAnimated))
        }
        .frame(width: 150, height: 120)
    }

    private var titleLabel: some View {
        Text(title)
            .font(.system(.headline))
            .fontWeight(.bold)
    }

    private var extraBounceSlider: some View {
        HStack(spacing: 4) {
            Text("extraBounce:")
                .font(.system(.caption2))
            Slider(value: $extraBounce, in: 0.0...0.5, step: 0.1)
                .frame(width: 70)
            Text(String(format: "%.1f", extraBounce))
                .font(.system(.caption))
                .frame(width: 28)
        }
        .foregroundStyle(.secondary)
    }

    private var codePreview: some View {
        Button {
            copyCode()
        } label: {
            Text(showCopied ? "Copied!" : codeString)
                .font(.system(.caption2))
                .foregroundStyle(showCopied ? .green : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 180, height: 32)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.background)
            .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
    }

    // MARK: - Actions

    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(".animation(\(codeString), value: trigger)", forType: .string)
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }

    private func restartLoop() {
        timer?.invalidate()
        isAnimated = false
        startLoop()
    }

    private func startLoop() {
        triggerAnimation()
        timer = Timer.scheduledTimer(withTimeInterval: loopInterval, repeats: true) { _ in
            triggerAnimation()
        }
    }

    private func triggerAnimation() {
        withAnimation(animation) {
            isAnimated = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + holdDuration) {
            withAnimation(animation) {
                isAnimated = false
            }
        }
    }
}
