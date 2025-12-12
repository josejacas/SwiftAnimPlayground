//
//  DemoShape.swift
//  AnimationDemo
//

import SwiftUI

enum DemoShape: String, CaseIterable {
    case roundedRect = "Rounded Rect"
    case circle = "Circle"
}


// MARK: - Shape View

struct DemoShapeView: View {
    let shape: DemoShape
    let color: Color
    let size: CGFloat

    init(shape: DemoShape, color: Color = .blue, size: CGFloat = 50) {
        self.shape = shape
        self.color = color
        self.size = size
    }

    var body: some View {
        switch shape {
        case .roundedRect:
            RoundedRectangle(cornerRadius: 12)
                .fill(color.gradient)
                .frame(width: size, height: size)
        case .circle:
            Circle()
                .fill(color.gradient)
                .frame(width: size, height: size)
        }
    }
}
