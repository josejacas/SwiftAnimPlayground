//
//  InteractiveCurveEditor.swift
//  AnimationDemo
//

import SwiftUI

struct InteractiveCurveEditor: View {
    @Binding var p1: CGPoint
    @Binding var p2: CGPoint
    @Binding var isDragging: Bool

    let size: CGSize

    private let padding: CGFloat = 40
    private let gridColor = Color.gray.opacity(0.15)
    private let axisColor = Color.gray.opacity(0.4)
    private let curveColor = Color.accentColor
    private let p1Color = Color.orange
    private let p2Color = Color.purple

    // Y bounds to allow overshoot/anticipate
    private let minY: Double = -2.0
    private let maxY: Double = 3.0

    // Extra vertical space for handles to overflow into
    private let overflowPadding: CGFloat = 60

    var body: some View {
        GeometryReader { geometry in
            // The graph rect stays within the visible background area
            let graphRect = CGRect(
                x: padding,
                y: overflowPadding + padding / 2,
                width: geometry.size.width - padding * 1.5,
                height: geometry.size.height - padding - overflowPadding * 2
            )

            ZStack {
                // Background only for the main graph area (not overflow)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .frame(width: size.width, height: size.height - overflowPadding * 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // Canvas for grid, axes, and curve - NOT clipped
                Canvas { context, canvasSize in
                    drawGrid(context: context, rect: graphRect)
                    drawAxes(context: context, rect: graphRect)
                    drawControlArms(context: context, rect: graphRect)
                    drawCurve(context: context, rect: graphRect)
                    drawEndpoints(context: context, rect: graphRect)
                }

                // Draggable control point handles
                ControlPointHandle(
                    position: $p1,
                    graphRect: graphRect,
                    color: p1Color,
                    label: "P1",
                    minY: minY,
                    maxY: maxY,
                    onDragChanged: { isDragging = true },
                    onDragEnded: { isDragging = false }
                )

                ControlPointHandle(
                    position: $p2,
                    graphRect: graphRect,
                    color: p2Color,
                    label: "P2",
                    minY: minY,
                    maxY: maxY,
                    onDragChanged: { isDragging = true },
                    onDragEnded: { isDragging = false }
                )
            }
        }
        .frame(width: size.width, height: size.height + overflowPadding * 2)
    }

    // MARK: - Drawing Functions

    private func drawGrid(context: GraphicsContext, rect: CGRect) {
        var gridPath = Path()
        let range = maxY - minY

        // Vertical lines (time axis)
        for i in 0...4 {
            let x = rect.minX + (CGFloat(i) / 4.0) * rect.width
            gridPath.move(to: CGPoint(x: x, y: rect.minY))
            gridPath.addLine(to: CGPoint(x: x, y: rect.maxY))
        }

        // Horizontal lines (value axis)
        let steps = Int((maxY - minY) / 0.25)
        for i in 0...steps {
            let normalizedY = CGFloat(i) / CGFloat(steps)
            let y = rect.maxY - normalizedY * rect.height
            gridPath.move(to: CGPoint(x: rect.minX, y: y))
            gridPath.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        context.stroke(gridPath, with: .color(gridColor), lineWidth: 1)
    }

    private func drawAxes(context: GraphicsContext, rect: CGRect) {
        let range = maxY - minY

        // Calculate screen positions for y=0 and y=1
        let y0Screen = rect.maxY - ((0 - minY) / range) * rect.height
        let y1Screen = rect.maxY - ((1 - minY) / range) * rect.height

        var axisPath = Path()

        // Y axis (left edge)
        axisPath.move(to: CGPoint(x: rect.minX, y: rect.minY))
        axisPath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        // X axis at y=0
        axisPath.move(to: CGPoint(x: rect.minX, y: y0Screen))
        axisPath.addLine(to: CGPoint(x: rect.maxX, y: y0Screen))

        context.stroke(axisPath, with: .color(axisColor), lineWidth: 1)

        // Dashed line at y=1
        var refPath = Path()
        refPath.move(to: CGPoint(x: rect.minX, y: y1Screen))
        refPath.addLine(to: CGPoint(x: rect.maxX, y: y1Screen))
        context.stroke(
            refPath,
            with: .color(Color.gray.opacity(0.3)),
            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
        )

        // Axis labels
        let labelFont = Font.system(size: 10, weight: .medium)

        // "0" label
        context.draw(
            Text("0").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.minX - 12, y: y0Screen)
        )

        // "1" label
        context.draw(
            Text("1").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.minX - 12, y: y1Screen)
        )

        // "t" label at end of X axis
        context.draw(
            Text("t").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.maxX + 10, y: y0Screen)
        )

        // "0" at start of X axis
        context.draw(
            Text("0").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.minX, y: rect.maxY + 12)
        )

        // "1" at end of X axis
        context.draw(
            Text("1").font(labelFont).foregroundColor(.secondary),
            at: CGPoint(x: rect.maxX, y: rect.maxY + 12)
        )
    }

    private func drawControlArms(context: GraphicsContext, rect: CGRect) {
        let range = maxY - minY

        // Start point (0,0)
        let startScreen = CGPoint(
            x: rect.minX,
            y: rect.maxY - ((0 - minY) / range) * rect.height
        )

        // End point (1,1)
        let endScreen = CGPoint(
            x: rect.maxX,
            y: rect.maxY - ((1 - minY) / range) * rect.height
        )

        // P1 screen position
        let p1Screen = CGPoint(
            x: rect.minX + p1.x * rect.width,
            y: rect.maxY - ((p1.y - minY) / range) * rect.height
        )

        // P2 screen position
        let p2Screen = CGPoint(
            x: rect.minX + p2.x * rect.width,
            y: rect.maxY - ((p2.y - minY) / range) * rect.height
        )

        // Draw control arm from start to P1
        var arm1Path = Path()
        arm1Path.move(to: startScreen)
        arm1Path.addLine(to: p1Screen)
        context.stroke(
            arm1Path,
            with: .color(p1Color.opacity(0.5)),
            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
        )

        // Draw control arm from end to P2
        var arm2Path = Path()
        arm2Path.move(to: endScreen)
        arm2Path.addLine(to: p2Screen)
        context.stroke(
            arm2Path,
            with: .color(p2Color.opacity(0.5)),
            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
        )
    }

    private func drawCurve(context: GraphicsContext, rect: CGRect) {
        let range = maxY - minY
        var curvePath = Path()

        let pointCount = 100
        for i in 0..<pointCount {
            let t = Double(i) / Double(pointCount - 1)
            let y = cubicBezier(t: t, p1: p1, p2: p2)

            let screenX = rect.minX + t * rect.width
            let screenY = rect.maxY - ((y - minY) / range) * rect.height

            if i == 0 {
                curvePath.move(to: CGPoint(x: screenX, y: screenY))
            } else {
                curvePath.addLine(to: CGPoint(x: screenX, y: screenY))
            }
        }

        context.stroke(curvePath, with: .color(curveColor), lineWidth: 2.5)
    }

    private func drawEndpoints(context: GraphicsContext, rect: CGRect) {
        let range = maxY - minY

        // Start point (0,0)
        let startScreen = CGPoint(
            x: rect.minX,
            y: rect.maxY - ((0 - minY) / range) * rect.height
        )

        // End point (1,1)
        let endScreen = CGPoint(
            x: rect.maxX,
            y: rect.maxY - ((1 - minY) / range) * rect.height
        )

        let endpointSize: CGFloat = 8

        // Draw start point
        let startRect = CGRect(
            x: startScreen.x - endpointSize / 2,
            y: startScreen.y - endpointSize / 2,
            width: endpointSize,
            height: endpointSize
        )
        context.fill(Circle().path(in: startRect), with: .color(curveColor))

        // Draw end point
        let endRect = CGRect(
            x: endScreen.x - endpointSize / 2,
            y: endScreen.y - endpointSize / 2,
            width: endpointSize,
            height: endpointSize
        )
        context.fill(Circle().path(in: endRect), with: .color(curveColor))
    }

    // MARK: - Cubic Bezier Math

    private func cubicBezier(t: Double, p1: CGPoint, p2: CGPoint) -> Double {
        let cx = 3.0 * p1.x
        let bx = 3.0 * (p2.x - p1.x) - cx
        let ax = 1.0 - cx - bx

        let cy = 3.0 * p1.y
        let by = 3.0 * (p2.y - p1.y) - cy
        let ay = 1.0 - cy - by

        // Find t for x using Newton-Raphson
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

// MARK: - Control Point Handle

struct ControlPointHandle: View {
    @Binding var position: CGPoint
    let graphRect: CGRect
    let color: Color
    let label: String
    let minY: Double
    let maxY: Double
    var onDragChanged: (() -> Void)? = nil
    var onDragEnded: (() -> Void)? = nil

    @State private var isDragging = false

    private let handleSize: CGFloat = 16

    var body: some View {
        let screenPos = screenPosition

        ZStack {
            // Handle circle
            Circle()
                .fill(color)
                .frame(width: handleSize, height: handleSize)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: color.opacity(isDragging ? 0.6 : 0.3), radius: isDragging ? 8 : 4)
                .scaleEffect(isDragging ? 1.3 : 1.0)

            // Coordinate label (shown while dragging)
            if isDragging {
                Text(String(format: "(%.2f, %.2f)", position.x, position.y))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.95))
                    .cornerRadius(4)
                    .offset(y: -28)
            }
        }
        .position(screenPos)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        onDragChanged?()
                    }
                    withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.8)) {
                        isDragging = true
                    }

                    // Convert screen position to normalized coordinates
                    let normalizedX = (value.location.x - graphRect.minX) / graphRect.width
                    let range = maxY - minY
                    let normalizedY = minY + (1.0 - (value.location.y - graphRect.minY) / graphRect.height) * range

                    // Clamp X to 0-1, Y to extended range
                    position = CGPoint(
                        x: max(0, min(1, normalizedX)),
                        y: max(minY, min(maxY, normalizedY))
                    )
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isDragging = false
                    }
                    onDragEnded?()
                }
        )
        .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.8), value: position)
    }

    private var screenPosition: CGPoint {
        let range = maxY - minY
        return CGPoint(
            x: graphRect.minX + position.x * graphRect.width,
            y: graphRect.maxY - ((position.y - minY) / range) * graphRect.height
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var p1 = CGPoint(x: 0.42, y: 0.0)
        @State private var p2 = CGPoint(x: 0.58, y: 1.0)
        @State private var isDragging = false

        var body: some View {
            InteractiveCurveEditor(
                p1: $p1,
                p2: $p2,
                isDragging: $isDragging,
                size: CGSize(width: 350, height: 300)
            )
            .padding()
        }
    }

    return PreviewWrapper()
}
