//
//  AnimationModifiers.swift
//  AnimationDemo
//

import SwiftUI

// MARK: - Standard Animation Modifier

struct AnimationModifier: ViewModifier {
    let type: AnimationType
    let isAnimated: Bool

    func body(content: Content) -> some View {
        switch type {
        case .scale:
            content
                .scaleEffect(isAnimated ? 2.5 : 1.0)
        case .movement:
            content
                .offset(x: isAnimated ? 50 : -50)
        case .rotation:
            content
                .rotationEffect(.degrees(isAnimated ? 180 : 0))
        }
    }
}

// MARK: - Additive Animation Modifier

struct AdditiveAnimationModifier: ViewModifier {
    let type: AnimationType
    let scale: Double
    let rotation: Double
    let offset: Double

    func body(content: Content) -> some View {
        switch type {
        case .scale:
            content.scaleEffect(scale)
        case .rotation:
            content.rotationEffect(.degrees(rotation))
        case .movement:
            content.offset(x: offset)
        }
    }
}
