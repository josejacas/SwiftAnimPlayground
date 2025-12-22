//
//  InterpolatingSpringDemoView.swift
//  AnimationDemo
//

import SwiftUI
import AppKit

struct InterpolatingSpringDemoView: View {
    let title: String
    let animationType: AnimationType
    let shape: DemoShape

    @State private var parameterValues: [String: Double] = [
        "stiffness": 170,
        "damping": 15
    ]
    @State private var showCopied = false

    private var stiffness: Double {
        parameterValues["stiffness"] ?? 170
    }

    private var damping: Double {
        parameterValues["damping"] ?? 15
    }

    // Additive animation values
    @State private var scaleValue: Double = 1.0
    @State private var rotationValue: Double = 0
    @State private var offsetValue: Double = 0
    @State private var movingRight = true

    private var animation: Animation {
        .interpolatingSpring(stiffness: stiffness, damping: damping)
    }

    private var codeString: String {
        "\(title)(stiffness: \(Int(stiffness)), damping: \(Int(damping)))"
    }

    var body: some View {
        VStack(spacing: 10) {
            animationArea
            instructionLabel
            titleLabel
            stiffnessSlider
            dampingSlider
            resetButton
            codePreview
        }
        .padding()
        .frame(width: 220, height: 320)
        .background(cardBackground)
        .overlay(alignment: .topTrailing) {
            InfoButton(curve: .interpolatingSpring, parameterValues: $parameterValues)
                .padding(12)
        }
    }

    // MARK: - View Components

    private var animationArea: some View {
        ZStack {
            DemoShapeView(shape: shape, color: .purple)
                .modifier(AdditiveAnimationModifier(
                    type: animationType,
                    scale: scaleValue,
                    rotation: rotationValue,
                    offset: offsetValue
                ))
        }
        .frame(width: 150, height: 100)
        .contentShape(Rectangle())
        .onTapGesture {
            addAnimation()
        }
    }

    private var instructionLabel: some View {
        Text("Click rapidly!")
            .font(.system(.caption2))
            .foregroundStyle(.purple)
    }

    private var titleLabel: some View {
        Text(title)
            .font(.system(.caption))
            .fontWeight(.bold)
    }

    private var stiffnessSpec: AnimationParameterSpec {
        AnimationCurve.interpolatingSpring.parameterSpecs.first { $0.id == "stiffness" }!
    }

    private var dampingSpec: AnimationParameterSpec {
        AnimationCurve.interpolatingSpring.parameterSpecs.first { $0.id == "damping" }!
    }

    private var stiffnessSlider: some View {
        HStack(spacing: 4) {
            Text("stiffness:")
                .font(.system(.caption2))
            Slider(
                value: Binding(
                    get: { parameterValues["stiffness"] ?? 170 },
                    set: { parameterValues["stiffness"] = $0 }
                ),
                in: stiffnessSpec.range,
                step: stiffnessSpec.step
            )
            .frame(width: 60)
            Text(stiffnessSpec.formatValue(stiffness))
                .font(.system(.caption2))
                .frame(width: 28)
        }
        .foregroundStyle(.secondary)
    }

    private var dampingSlider: some View {
        HStack(spacing: 4) {
            Text("damping:")
                .font(.system(.caption2))
            Slider(
                value: Binding(
                    get: { parameterValues["damping"] ?? 15 },
                    set: { parameterValues["damping"] = $0 }
                ),
                in: dampingSpec.range,
                step: dampingSpec.step
            )
            .frame(width: 60)
            Text(dampingSpec.formatValue(damping))
                .font(.system(.caption2))
                .frame(width: 28)
        }
        .foregroundStyle(.secondary)
    }

    private var resetButton: some View {
        Button("Reset") {
            withAnimation(animation) {
                scaleValue = 1.0
                rotationValue = 0
                offsetValue = 0
                movingRight = true
            }
        }
        .font(.caption)
        .foregroundStyle(.purple)
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
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
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
                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
            )
    }

    // MARK: - Actions

    private func addAnimation() {
        withAnimation(animation) {
            switch animationType {
            case .scale:
                if scaleValue >= 2.2 {
                    scaleValue = 1.0
                } else {
                    scaleValue += 0.15
                }
            case .rotation:
                rotationValue += 30
            case .movement:
                if movingRight {
                    offsetValue += 12
                    if offsetValue >= 48 {
                        movingRight = false
                    }
                } else {
                    offsetValue -= 12
                    if offsetValue <= -48 {
                        movingRight = true
                    }
                }
            }
        }
    }

    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(".animation(\(codeString), value: trigger)", forType: .string)
        showCopied = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            showCopied = false
        }
    }
}
