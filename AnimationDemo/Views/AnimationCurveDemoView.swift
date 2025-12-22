//
//  AnimationCurveDemoView.swift
//  AnimationDemo
//

import SwiftUI
import AppKit

struct AnimationCurveDemoView: View {
    let curve: AnimationCurve
    let duration: Double
    let holdDuration: Double
    let animationType: AnimationType
    let shape: DemoShape

    @State private var parameterValues: [String: Double] = [:]
    @State private var isAnimated = false
    @State private var timer: Timer?
    @State private var showCopied = false

    init(curve: AnimationCurve, duration: Double, holdDuration: Double, animationType: AnimationType, shape: DemoShape) {
        self.curve = curve
        self.duration = duration
        self.holdDuration = holdDuration
        self.animationType = animationType
        self.shape = shape
        _parameterValues = State(initialValue: curve.defaultParameterValues)
    }

    private var animation: Animation {
        curve.buildAnimation(with: parameterValues, duration: duration)
    }

    private var loopInterval: Double {
        duration + holdDuration + duration + 0.3
    }

    private var codeString: String {
        curve.codeString(with: parameterValues, duration: duration)
    }

    private var editableSpecs: [AnimationParameterSpec] {
        curve.editableParameterSpecs
    }

    var body: some View {
        VStack(spacing: 12) {
            animationArea
            titleLabel
            parameterSlidersArea
            codePreview
        }
        .padding()
        .frame(width: 220, height: 280)
        .background(cardBackground)
        .overlay(alignment: .topTrailing) {
            InfoButton(curve: curve, parameterValues: $parameterValues)
                .padding(12)
        }
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
        Text(curve.rawValue)
            .font(.system(.headline))
            .fontWeight(.bold)
    }

    private var parameterSlidersArea: some View {
        VStack(spacing: 8) {
            ForEach(editableSpecs) { spec in
                parameterSlider(for: spec)
            }
        }
        .frame(height: 24, alignment: .top)
    }

    private func parameterSlider(for spec: AnimationParameterSpec) -> some View {
        HStack(spacing: 4) {
            Text("\(spec.name):")
                .font(.system(.caption2))
            Slider(
                value: Binding(
                    get: { parameterValues[spec.id] ?? spec.defaultValue },
                    set: { parameterValues[spec.id] = $0 }
                ),
                in: spec.range,
                step: spec.step
            )
            .frame(width: 70)
            Text(spec.formatValue(parameterValues[spec.id] ?? spec.defaultValue))
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
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration + holdDuration))
            withAnimation(animation) {
                isAnimated = false
            }
        }
    }
}
