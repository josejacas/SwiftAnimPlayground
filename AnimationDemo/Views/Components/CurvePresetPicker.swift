//
//  CurvePresetPicker.swift
//  AnimationDemo
//

import SwiftUI

struct CurvePresetPicker: View {
    @Binding var selectedCurve: CustomCurve
    var onPresetSelected: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(CustomCurve.presetGroups) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(group.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 8) {
                            ForEach(group.curves) { curve in
                                PresetButton(
                                    curve: curve,
                                    isSelected: isSelected(curve),
                                    action: { selectPreset(curve) }
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func isSelected(_ curve: CustomCurve) -> Bool {
        selectedCurve.p1 == curve.p1 && selectedCurve.p2 == curve.p2
    }

    private func selectPreset(_ curve: CustomCurve) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedCurve.p1 = curve.p1
            selectedCurve.p2 = curve.p2
            selectedCurve.name = curve.name
        }
        onPresetSelected?()
    }
}

// MARK: - Preset Button

struct PresetButton: View {
    let curve: CustomCurve
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Mini curve preview
                MiniCurvePreview(curve: curve)
                    .frame(width: 50, height: 35)

                Text(curve.name)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mini Curve Preview

struct MiniCurvePreview: View {
    let curve: CustomCurve

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 4, dy: 4)

            // Draw curve
            var path = Path()
            let pointCount = 50

            for i in 0..<pointCount {
                let t = Double(i) / Double(pointCount - 1)
                let y = cubicBezier(t: t, p1: curve.p1, p2: curve.p2)

                // Clamp y for display
                let clampedY = max(-0.2, min(1.2, y))
                let normalizedY = (clampedY + 0.2) / 1.4

                let screenX = rect.minX + t * rect.width
                let screenY = rect.maxY - normalizedY * rect.height

                if i == 0 {
                    path.move(to: CGPoint(x: screenX, y: screenY))
                } else {
                    path.addLine(to: CGPoint(x: screenX, y: screenY))
                }
            }

            context.stroke(path, with: .color(.accentColor), lineWidth: 1.5)
        }
    }

    private func cubicBezier(t: Double, p1: CGPoint, p2: CGPoint) -> Double {
        let cx = 3.0 * p1.x
        let bx = 3.0 * (p2.x - p1.x) - cx
        let ax = 1.0 - cx - bx

        let cy = 3.0 * p1.y
        let by = 3.0 * (p2.y - p1.y) - cy
        let ay = 1.0 - cy - by

        var tCurve = t
        for _ in 0..<8 {
            let xCurrent = ((ax * tCurve + bx) * tCurve + cx) * tCurve
            let xDerivative = (3.0 * ax * tCurve + 2.0 * bx) * tCurve + cx
            if abs(xDerivative) < 1e-6 { break }
            tCurve = tCurve - (xCurrent - t) / xDerivative
        }

        return ((ay * tCurve + by) * tCurve + cy) * tCurve
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var curve = CustomCurve.easeInOut

        var body: some View {
            CurvePresetPicker(selectedCurve: $curve)
                .frame(width: 250, height: 500)
        }
    }

    return PreviewWrapper()
}
