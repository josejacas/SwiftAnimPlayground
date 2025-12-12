//
//  ComparisonSlot.swift
//  AnimationDemo
//

import SwiftUI

struct ComparisonSlot: Identifiable, Equatable {
    let id = UUID()
    var curve: AnimationCurve
    var bounce: Double = 0.3        // For .spring
    var extraBounce: Double = 0.0   // For .snappy, .bouncy
    var isAnimated: Bool = false

    var color: Color

    static let slotColors: [Color] = [.blue, .orange, .green]

    func animation(duration: Double) -> Animation {
        switch curve {
        case .defaultCurve:
            return .default
        case .linear:
            return .linear(duration: duration)
        case .easeIn:
            return .easeIn(duration: duration)
        case .easeOut:
            return .easeOut(duration: duration)
        case .easeInOut:
            return .easeInOut(duration: duration)
        case .smooth:
            return .smooth(duration: duration)
        case .spring:
            return .spring(duration: duration, bounce: bounce)
        case .snappy:
            return .snappy(duration: duration, extraBounce: extraBounce)
        case .bouncy:
            return .bouncy(duration: duration, extraBounce: extraBounce)
        case .interpolatingSpring, .interactiveSpring:
            // These shouldn't be used in compare mode
            return .default
        }
    }

    var hasParameters: Bool {
        switch curve {
        case .spring, .snappy, .bouncy:
            return true
        default:
            return false
        }
    }
}
