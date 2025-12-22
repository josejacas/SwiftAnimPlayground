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
        GlobalControlsBar(
            animationType: $animationType,
            demoShape: $demoShape,
            duration: $globalDuration,
            holdDuration: $holdDuration
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
                GeometryReader { geometry in
                    let sidePadding: CGFloat = 48
                    let availableWidth = geometry.size.width - (sidePadding * 2)

                    VStack(spacing: 16) {
                        // Display mode picker - stays at top
                        Picker("", selection: $displayMode) {
                            ForEach(CompareDisplayMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                        .padding(.top, 16)

                        Spacer()

                        // Animated shapes area
                        ZStack {
                            ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                                DemoShapeView(shape: demoShape, color: slot.color)
                                    .scaleEffect(displayMode == .stacked ? 1.8 : 1.3)
                                    .opacity(displayMode == .stacked ? 0.65 : 1.0)
                                    .modifier(CompareAnimationModifier(
                                        type: animationType,
                                        isAnimated: slot.isAnimated,
                                        useVerticalMovement: displayMode == .sideBySide
                                    ))
                                    .offset(x: adaptiveOffset(for: index, availableWidth: availableWidth))
                                    .animation(.spring(duration: 0.5, bounce: 0.3), value: displayMode)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .padding(.bottom, 64)

                        // Curve visualizations
                        curveVisualizationsArea(availableWidth: availableWidth)
                            .padding(.horizontal, sidePadding)

                        Spacer()
                    }
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                }
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

            // Dynamic parameter sliders from parameterSpecs
            ForEach(slot.wrappedValue.editableParameters) { param in
                HStack(spacing: 4) {
                    Text("\(param.name):")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Slider(
                        value: parameterBinding(for: param.id, in: slot),
                        in: param.range,
                        step: param.step
                    )
                    .frame(width: 70)
                    Text(param.formatValue(slot.wrappedValue.parameterValues[param.id] ?? param.defaultValue))
                        .font(.caption)
                        .frame(width: 28)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(slot.wrappedValue.color.opacity(0.1))
        )
    }

    /// Creates a binding to a specific parameter value in the slot
    private func parameterBinding(for paramId: String, in slot: Binding<ComparisonSlot>) -> Binding<Double> {
        Binding(
            get: {
                slot.wrappedValue.parameterValues[paramId] ??
                    slot.wrappedValue.curve.parameterSpecs.first { $0.id == paramId }?.defaultValue ?? 0.0
            },
            set: { newValue in
                slot.wrappedValue.parameterValues[paramId] = newValue
            }
        )
    }

    // MARK: - Curve Visualizations

    private let stackedGraphSize = CGSize(width: 400, height: 160)
    private let sideBySideGraphSize = CGSize(width: 180, height: 130)

    private func curveVisualizationsArea(availableWidth: CGFloat) -> some View {
        VStack(spacing: 8) {
            // Graphs - use ZStack with offsets for smooth animation
            ZStack {
                ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                    CompareCurveGraphView(
                        slots: displayMode == .stacked ? slots : [slot],
                        size: displayMode == .stacked ? stackedGraphSize : sideBySideGraphSize
                    )
                    .opacity(displayMode == .stacked && index > 0 ? 0 : 1)
                    .offset(x: adaptiveOffset(for: index, availableWidth: availableWidth))
                    .animation(.spring(duration: 0.5, bounce: 0.3), value: displayMode)
                }
            }
            .frame(
                width: displayMode == .stacked ? stackedGraphSize.width : nil,
                height: displayMode == .stacked ? stackedGraphSize.height : sideBySideGraphSize.height
            )
            .frame(maxWidth: displayMode == .stacked ? nil : .infinity)
            .animation(.spring(duration: 0.5, bounce: 0.3), value: displayMode)

            // Legend - use ZStack with offsets for smooth animation
            ZStack {
                ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                    legendItem(for: slot)
                        .offset(x: adaptiveOffset(for: index, availableWidth: availableWidth))
                        .animation(.spring(duration: 0.5, bounce: 0.3), value: displayMode)
                }
            }
            .frame(maxWidth: displayMode == .stacked ? nil : .infinity)
        }
    }

    private func legendItem(for slot: ComparisonSlot) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(slot.color)
                .frame(width: 8, height: 8)
            Text(slot.curve.rawValue)
                .font(.caption2)
                .foregroundStyle(slot.color)
        }
    }

    // MARK: - Layout Helpers

    /// Calculates adaptive offset for items based on available width
    private func adaptiveOffset(for index: Int, availableWidth: CGFloat) -> CGFloat {
        guard displayMode == .sideBySide else { return 0 }

        let count = slots.count
        guard count > 1 else { return 0 }

        // Spacing constraints
        let itemWidth: CGFloat = 180
        let minSpacing: CGFloat = 20
        let maxSpacing: CGFloat = 120  // Cap maximum distance between item centers

        // Calculate ideal spacing to distribute evenly
        let idealSpacing = (availableWidth - CGFloat(count) * itemWidth) / CGFloat(count - 1) + itemWidth

        // Clamp spacing between min and max
        let actualSpacing = min(max(idealSpacing, itemWidth + minSpacing), itemWidth + maxSpacing)

        // Center the items
        let totalWidth = actualSpacing * CGFloat(count - 1)
        let startX = -totalWidth / 2

        return startX + CGFloat(index) * actualSpacing
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

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(globalDuration + holdDuration))
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
