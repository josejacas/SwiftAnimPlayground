//
//  PlaygroundView.swift
//  AnimationDemo
//

import SwiftUI

struct PlaygroundView: View {
    @State private var globalDuration: Double = 0.6
    @State private var holdDuration: Double = 1.5
    @State private var animationType: AnimationType = .scale
    @State private var demoShape: DemoShape = .roundedRect
    @State private var isStandardExpanded = true
    @State private var isInteractiveExpanded = true

    var body: some View {
        VStack(spacing: 20) {
            globalControls
            animationGrid
        }
        .padding(32)
        .frame(minWidth: 600, minHeight: 500)
        .background(Color.gray.opacity(0.04))
    }

    // MARK: - Global Controls

    private var globalControls: some View {
        VStack(spacing: 32) {
            HStack(spacing: 32) {
                Picker("", selection: $animationType) {
                    ForEach(AnimationType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 240)

                Divider()
                    .frame(height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Shape")
                        .font(.system(.caption, weight: .medium))
                        .foregroundStyle(.secondary)
                    Picker("", selection: $demoShape) {
                        ForEach(DemoShape.allCases, id: \.self) { shape in
                            Text(shape.rawValue).tag(shape)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                Divider()
                    .frame(height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.system(.caption, weight: .medium))
                        .foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        Slider(value: $globalDuration, in: 0.2...1.5, step: 0.1)
                            .frame(width: 100)
                            .tint(.blue)
                        Text(String(format: "%.1fs", globalDuration))
                            .font(.system(.subheadline))
                            .foregroundStyle(.primary)
                            .frame(width: 36)
                            .monospacedDigit()
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Hold")
                        .font(.system(.caption, weight: .medium))
                        .foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        Slider(value: $holdDuration, in: 0.5...3.0, step: 0.25)
                            .frame(width: 100)
                            .tint(.blue)
                        Text(String(format: "%.1fs", holdDuration))
                            .font(.system(.subheadline))
                            .foregroundStyle(.primary)
                            .frame(width: 36)
                            .monospacedDigit()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            )

            Text("Compare how different animation curves affect movement.\nClick on the code snippets to copy to clipboard.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Animation Grid

    private var animationGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 220, maximum: 280), spacing: 20)]

        return ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                standardAnimationsSection(columns: columns)
                interactiveAnimationsSection(columns: columns)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Animation Sections

    @ViewBuilder
    private func standardAnimationsSection(columns: [GridItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isStandardExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isStandardExpanded ? 90 : 0))

                    Text("Standard Animations")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isStandardExpanded {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(AnimationCurve.standardCurves) { curve in
                        animationView(for: curve)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func interactiveAnimationsSection(columns: [GridItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isInteractiveExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.purple)
                        .rotationEffect(.degrees(isInteractiveExpanded ? 90 : 0))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Interactive Animations")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.purple)

                        Text("Click or drag to trigger - designed for gesture-driven interactions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            if isInteractiveExpanded {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(AnimationCurve.interactiveCurves) { curve in
                        animationView(for: curve)
                    }
                }
            }
        }
    }

    // MARK: - View Factory

    @ViewBuilder
    private func animationView(for curve: AnimationCurve) -> some View {
        switch curve {
        case .defaultCurve:
            AnimationCurveDemoView(
                animation: .default,
                title: curve.rawValue,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .linear:
            AnimationCurveDemoView(
                animation: .linear(duration: globalDuration),
                title: curve.rawValue,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .easeIn:
            AnimationCurveDemoView(
                animation: .easeIn(duration: globalDuration),
                title: curve.rawValue,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .easeOut:
            AnimationCurveDemoView(
                animation: .easeOut(duration: globalDuration),
                title: curve.rawValue,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .easeInOut:
            AnimationCurveDemoView(
                animation: .easeInOut(duration: globalDuration),
                title: curve.rawValue,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .smooth:
            AnimationCurveDemoView(
                animation: .smooth(duration: globalDuration),
                title: curve.rawValue,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .spring:
            SpringDemoView(
                title: curve.rawValue,
                initialBounce: 0.3,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .snappy:
            SnappyDemoView(
                title: curve.rawValue,
                initialExtraBounce: 0.0,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .bouncy:
            BouncyDemoView(
                title: curve.rawValue,
                initialExtraBounce: 0.0,
                duration: globalDuration,
                holdDuration: holdDuration,
                animationType: animationType,
                shape: demoShape
            )
        case .interpolatingSpring:
            InterpolatingSpringDemoView(
                title: curve.rawValue,
                animationType: animationType,
                shape: demoShape
            )
        case .interactiveSpring:
            InteractiveSpringDemoView(
                title: curve.rawValue,
                animationType: animationType,
                shape: demoShape
            )
        }
    }
}

#Preview {
    PlaygroundView()
}
