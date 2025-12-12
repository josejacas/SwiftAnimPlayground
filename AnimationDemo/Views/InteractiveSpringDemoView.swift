//
//  InteractiveSpringDemoView.swift
//  AnimationDemo
//

import SwiftUI
import AppKit

struct InteractiveSpringDemoView: View {
    let title: String
    let animationType: AnimationType
    let shape: DemoShape

    @State private var response: Double = 0.4
    @State private var dampingFraction: Double = 0.7
    @State private var showCopied = false

    // Gesture tracking
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    // Scale/rotation for gesture interactions
    @State private var currentScale: Double = 1.0
    @State private var currentRotation: Double = 0

    private var animation: Animation {
        .interactiveSpring(response: response, dampingFraction: dampingFraction)
    }

    private var codeString: String {
        "\(title)(response: \(String(format: "%.1f", response)), dampingFraction: \(String(format: "%.1f", dampingFraction)))"
    }

    var body: some View {
        VStack(spacing: 10) {
            animationArea
            instructionLabel
            titleLabel
            responseSlider
            dampingSlider
            codePreview
        }
        .padding()
        .frame(width: 220, height: 320)
        .background(cardBackground)
    }

    // MARK: - View Components

    private var animationArea: some View {
        ZStack {
            Circle()
                .stroke(Color.purple.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(width: 80, height: 80)

            DemoShapeView(shape: shape, color: .purple)
                .scaleEffect(currentScale)
                .rotationEffect(.degrees(currentRotation))
                .offset(dragOffset)
                .gesture(dragGesture)
        }
        .frame(width: 150, height: 100)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                withAnimation(animation) {
                    switch animationType {
                    case .movement:
                        dragOffset = CGSize(
                            width: max(-70, min(70, value.translation.width)),
                            height: max(-50, min(50, value.translation.height))
                        )
                    case .scale:
                        let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        currentScale = 1.0 + (distance / 150)
                        currentScale = max(0.5, min(2.0, currentScale))
                    case .rotation:
                        currentRotation = value.translation.width * 0.5
                    }
                }
            }
            .onEnded { _ in
                isDragging = false
                withAnimation(animation) {
                    dragOffset = .zero
                    currentScale = 1.0
                    currentRotation = 0
                }
            }
    }

    private var instructionLabel: some View {
        Text(isDragging ? "Release to spring back!" : "Drag me!")
            .font(.system(.caption2))
            .foregroundStyle(.purple)
    }

    private var titleLabel: some View {
        Text(title)
            .font(.system(.caption))
            .fontWeight(.bold)
    }

    private var responseSlider: some View {
        HStack(spacing: 4) {
            Text("response:")
                .font(.system(.caption2))
            Slider(value: $response, in: 0.1...1.0, step: 0.1)
                .frame(width: 60)
            Text(String(format: "%.1f", response))
                .font(.system(.caption2))
                .frame(width: 28)
        }
        .foregroundStyle(.secondary)
    }

    private var dampingSlider: some View {
        HStack(spacing: 4) {
            Text("damping:")
                .font(.system(.caption2))
            Slider(value: $dampingFraction, in: 0.1...1.0, step: 0.1)
                .frame(width: 60)
            Text(String(format: "%.1f", dampingFraction))
                .font(.system(.caption2))
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

    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(".animation(\(codeString), value: trigger)", forType: .string)
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }
}
