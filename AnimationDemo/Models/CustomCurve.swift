//
//  CustomCurve.swift
//  AnimationDemo
//

import SwiftUI

/// Represents a custom cubic Bézier timing curve with two control points
struct CustomCurve: Identifiable, Equatable {
    let id: UUID
    var name: String
    var p1: CGPoint  // First control handle (controls ease-in behavior)
    var p2: CGPoint  // Second control handle (controls ease-out behavior)
    var duration: Double

    init(
        id: UUID = UUID(),
        name: String = "Custom",
        p1: CGPoint = CGPoint(x: 0.42, y: 0.0),
        p2: CGPoint = CGPoint(x: 0.58, y: 1.0),
        duration: Double = 0.5
    ) {
        self.id = id
        self.name = name
        self.p1 = p1
        self.p2 = p2
        self.duration = duration
    }

    /// Builds a SwiftUI Animation using timingCurve
    func buildAnimation() -> Animation {
        .timingCurve(p1.x, p1.y, p2.x, p2.y, duration: duration)
    }

    /// Generates copyable code string for .timingCurve
    func codeString() -> String {
        let c0x = formatDouble(p1.x)
        let c0y = formatDouble(p1.y)
        let c1x = formatDouble(p2.x)
        let c1y = formatDouble(p2.y)
        let dur = formatDouble(duration, decimals: 1)
        return ".timingCurve(\(c0x), \(c0y), \(c1x), \(c1y), duration: \(dur))"
    }

    /// Full animation call for copying
    func fullCodeString() -> String {
        ".animation(\(codeString()), value: trigger)"
    }

    private func formatDouble(_ value: Double, decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f", value)
    }
}

// MARK: - Preset Curves

extension CustomCurve {

    // MARK: Standard Easings

    static let linear = CustomCurve(
        name: "Linear",
        p1: CGPoint(x: 0.0, y: 0.0),
        p2: CGPoint(x: 1.0, y: 1.0)
    )

    static let easeIn = CustomCurve(
        name: "Ease In",
        p1: CGPoint(x: 0.42, y: 0.0),
        p2: CGPoint(x: 1.0, y: 1.0)
    )

    static let easeOut = CustomCurve(
        name: "Ease Out",
        p1: CGPoint(x: 0.0, y: 0.0),
        p2: CGPoint(x: 0.58, y: 1.0)
    )

    static let easeInOut = CustomCurve(
        name: "Ease In Out",
        p1: CGPoint(x: 0.42, y: 0.0),
        p2: CGPoint(x: 0.58, y: 1.0)
    )

    // MARK: Quad/Cubic Variants

    static let easeInQuad = CustomCurve(
        name: "Ease In Quad",
        p1: CGPoint(x: 0.55, y: 0.085),
        p2: CGPoint(x: 0.68, y: 0.53)
    )

    static let easeOutQuad = CustomCurve(
        name: "Ease Out Quad",
        p1: CGPoint(x: 0.25, y: 0.46),
        p2: CGPoint(x: 0.45, y: 0.94)
    )

    static let easeInCubic = CustomCurve(
        name: "Ease In Cubic",
        p1: CGPoint(x: 0.55, y: 0.055),
        p2: CGPoint(x: 0.675, y: 0.19)
    )

    static let easeOutCubic = CustomCurve(
        name: "Ease Out Cubic",
        p1: CGPoint(x: 0.215, y: 0.61),
        p2: CGPoint(x: 0.355, y: 1.0)
    )

    static let easeInOutCubic = CustomCurve(
        name: "Ease In Out Cubic",
        p1: CGPoint(x: 0.645, y: 0.045),
        p2: CGPoint(x: 0.355, y: 1.0)
    )

    // MARK: Expressive

    static let anticipate = CustomCurve(
        name: "Anticipate",
        p1: CGPoint(x: 0.36, y: 0.0),
        p2: CGPoint(x: 0.66, y: -0.56)
    )

    static let overshoot = CustomCurve(
        name: "Overshoot",
        p1: CGPoint(x: 0.34, y: 1.56),
        p2: CGPoint(x: 0.64, y: 1.0)
    )

    static let anticipateOvershoot = CustomCurve(
        name: "Anticipate + Overshoot",
        p1: CGPoint(x: 0.68, y: -0.55),
        p2: CGPoint(x: 0.265, y: 1.55)
    )

    // MARK: Snappy/UI

    static let snapIn = CustomCurve(
        name: "Snap In",
        p1: CGPoint(x: 0.755, y: 0.05),
        p2: CGPoint(x: 0.855, y: 0.06)
    )

    static let snapOut = CustomCurve(
        name: "Snap Out",
        p1: CGPoint(x: 0.23, y: 1.0),
        p2: CGPoint(x: 0.32, y: 1.0)
    )

    static let sharp = CustomCurve(
        name: "Sharp",
        p1: CGPoint(x: 0.4, y: 0.0),
        p2: CGPoint(x: 1.0, y: 1.0)
    )

    // MARK: Smooth/Soft

    static let softAccel = CustomCurve(
        name: "Soft Accelerate",
        p1: CGPoint(x: 0.12, y: 0.0),
        p2: CGPoint(x: 0.39, y: 0.0)
    )

    static let softDecel = CustomCurve(
        name: "Soft Decelerate",
        p1: CGPoint(x: 0.61, y: 1.0),
        p2: CGPoint(x: 0.88, y: 1.0)
    )

    static let gentle = CustomCurve(
        name: "Gentle",
        p1: CGPoint(x: 0.25, y: 0.1),
        p2: CGPoint(x: 0.25, y: 1.0)
    )
}

// MARK: - Preset Groups

struct CurvePresetGroup: Identifiable {
    let id = UUID()
    let name: String
    let curves: [CustomCurve]
}

extension CustomCurve {
    static let presetGroups: [CurvePresetGroup] = [
        CurvePresetGroup(name: "Standard", curves: [
            .linear,
            .easeIn,
            .easeOut,
            .easeInOut
        ]),
        CurvePresetGroup(name: "Cubic", curves: [
            .easeInQuad,
            .easeOutQuad,
            .easeInCubic,
            .easeOutCubic,
            .easeInOutCubic
        ]),
        CurvePresetGroup(name: "Expressive", curves: [
            .anticipate,
            .overshoot,
            .anticipateOvershoot
        ]),
        CurvePresetGroup(name: "Snappy", curves: [
            .snapIn,
            .snapOut,
            .sharp
        ]),
        CurvePresetGroup(name: "Smooth", curves: [
            .softAccel,
            .softDecel,
            .gentle
        ])
    ]

    static let allPresets: [CustomCurve] = presetGroups.flatMap { $0.curves }
}
