//
//  AppMode.swift
//  AnimationDemo
//

import Foundation

enum AppMode: String, CaseIterable, Identifiable {
    case playground = "Playground"
    case compare = "Compare"
    case examples = "Examples"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .playground: return "square.grid.2x2"
        case .compare: return "square.stack.3d.up"
        case .examples: return "sparkles.rectangle.stack"
        }
    }
}
