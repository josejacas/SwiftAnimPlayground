//
//  CompareView.swift
//  AnimationDemo
//

import SwiftUI

enum CompareDisplayMode: String, CaseIterable {
    case stacked = "Stacked"
    case sideBySide = "Side by Side"
}

struct CompareView: View {
    @State private var globalDuration: Double = 0.6
    @State private var holdDuration: Double = 1.5
    @State private var animationType: AnimationType = .scale
    @State private var demoShape: DemoShape = .roundedRect
    @State private var displayMode: CompareDisplayMode = .stacked

    @State private var slots: [ComparisonSlot] = []
    @State private var timer: Timer?

    private var loopInterval: Double {
        globalDuration + holdDuration + globalDuration + 0.3
    }

    var body: some View {
        VStack(spacing: 20) {
            globalControls
            curvePickerStrip
            comparisonArea
        }
        .padding(32)
        .frame(minWidth: 600, minHeight: 500)
        .background(Color.gray.opacity(0.04))
        .onAppear { startLoop() }
        .onDisappear { timer?.invalidate() }
        .onChange(of: globalDuration) { restartLoop() }
        .onChange(of: holdDuration) { restartLoop() }
        .onChange(of: animationType) { restartLoop() }
    }

    // MARK: - Global Controls

    private var globalControls: some View {
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
    }

    // MARK: - Curve Picker Strip

    private var curvePickerStrip: some View {
        VStack(spacing: 8) {
            Text("Drag curves to compare (up to 3)")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            HStack(spacing: 12) {
                ForEach(AnimationCurve.standardCurves) { curve in
                    DraggableCurveChip(curve: curve)
                }
            }
        }
    }

    // MARK: - Comparison Area

    private var comparisonArea: some View {
        HStack(spacing: 24) {
            // Main comparison card
            comparisonCard
                .frame(maxWidth: .infinity)

            // Parameter controls for active slots
            if !slots.isEmpty {
                parameterPanel
                    .frame(width: 220)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var comparisonCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)

            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    slots.isEmpty ? Color.gray.opacity(0.3) : Color.clear,
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )

            if slots.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                    Text("Drop curves here to compare")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Up to 3 curves can be stacked")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            } else {
                VStack(spacing: 16) {
                    // Display mode picker
                    Picker("", selection: $displayMode) {
                        ForEach(CompareDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)

                    // Animated shapes
                    ZStack {
                        ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                            DemoShapeView(shape: demoShape, color: slot.color)
                                .scaleEffect(displayMode == .stacked ? 2.0 : 1.5)
                                .opacity(displayMode == .stacked ? 0.65 : 1.0)
                                .modifier(CompareAnimationModifier(
                                    type: animationType,
                                    isAnimated: slot.isAnimated,
                                    useVerticalMovement: displayMode == .sideBySide
                                ))
                                .offset(x: horizontalOffset(for: index))
                                .animation(.spring(duration: 0.5, bounce: 0.3), value: displayMode)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.top, 16)
            }
        }
        .frame(minHeight: 300)
        .dropDestination(for: String.self) { items, _ in
            guard let curveRaw = items.first,
                  let curve = AnimationCurve.standardCurves.first(where: { $0.rawValue == curveRaw }),
                  slots.count < 3 else {
                return false
            }

            let colorIndex = slots.count
            let newSlot = ComparisonSlot(
                curve: curve,
                color: ComparisonSlot.slotColors[colorIndex]
            )
            slots.append(newSlot)
            restartLoop()
            return true
        }
    }

    private var parameterPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Curves")
                .font(.headline)
                .foregroundStyle(.secondary)

            ForEach($slots) { $slot in
                slotControl(slot: $slot)
            }

            Spacer()

            Button(role: .destructive) {
                slots.removeAll()
                restartLoop()
            } label: {
                Label("Clear All", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(slots.isEmpty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
        )
    }

    @ViewBuilder
    private func slotControl(slot: Binding<ComparisonSlot>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(slot.wrappedValue.color.gradient)
                    .frame(width: 12, height: 12)

                Text(slot.wrappedValue.curve.rawValue)
                    .font(.system(.subheadline, weight: .medium))

                Spacer()

                Button {
                    if let index = slots.firstIndex(where: { $0.id == slot.wrappedValue.id }) {
                        slots.remove(at: index)
                        restartLoop()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Parameter sliders based on curve type
            switch slot.wrappedValue.curve {
            case .spring:
                HStack(spacing: 4) {
                    Text("bounce:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Slider(value: slot.bounce, in: 0.0...0.9)
                        .frame(width: 80)
                    Text(String(format: "%.1f", slot.wrappedValue.bounce))
                        .font(.caption)
                        .frame(width: 28)
                }
            case .snappy, .bouncy:
                HStack(spacing: 4) {
                    Text("extraBounce:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Slider(value: slot.extraBounce, in: 0.0...0.5)
                        .frame(width: 60)
                    Text(String(format: "%.1f", slot.wrappedValue.extraBounce))
                        .font(.caption)
                        .frame(width: 28)
                }
            default:
                EmptyView()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(slot.wrappedValue.color.opacity(0.1))
        )
    }

    // MARK: - Layout Helpers

    private func horizontalOffset(for index: Int) -> CGFloat {
        guard displayMode == .sideBySide else { return 0 }

        let spacing: CGFloat = 180
        let count = slots.count

        switch count {
        case 1:
            return 0
        case 2:
            return index == 0 ? -spacing / 2 : spacing / 2
        case 3:
            return CGFloat(index - 1) * spacing
        default:
            return 0
        }
    }

    // MARK: - Animation Loop

    private func restartLoop() {
        timer?.invalidate()
        for index in slots.indices {
            slots[index].isAnimated = false
        }
        startLoop()
    }

    private func startLoop() {
        guard !slots.isEmpty else { return }
        triggerAnimation()
        timer = Timer.scheduledTimer(withTimeInterval: loopInterval, repeats: true) { _ in
            triggerAnimation()
        }
    }

    private func triggerAnimation() {
        guard !slots.isEmpty else { return }

        // Animate each slot with its own curve
        for index in slots.indices {
            withAnimation(slots[index].animation(duration: globalDuration)) {
                slots[index].isAnimated = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + globalDuration + holdDuration) {
            for index in slots.indices {
                withAnimation(slots[index].animation(duration: globalDuration)) {
                    slots[index].isAnimated = false
                }
            }
        }
    }
}

// MARK: - Draggable Curve Chip

struct DraggableCurveChip: View {
    let curve: AnimationCurve

    var body: some View {
        Text(curve.rawValue)
            .font(.system(.caption, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .draggable(curve.rawValue)
    }
}

// MARK: - Compare Animation Modifier

struct CompareAnimationModifier: ViewModifier {
    let type: AnimationType
    let isAnimated: Bool
    let useVerticalMovement: Bool

    func body(content: Content) -> some View {
        switch type {
        case .scale:
            content
                .scaleEffect(isAnimated ? 1.8 : 1.0)
        case .movement:
            if useVerticalMovement {
                content
                    .offset(y: isAnimated ? 40 : -40)
            } else {
                content
                    .offset(x: isAnimated ? 50 : -50)
            }
        case .rotation:
            content
                .rotationEffect(.degrees(isAnimated ? 180 : 0))
        }
    }
}

#Preview {
    CompareView()
}
