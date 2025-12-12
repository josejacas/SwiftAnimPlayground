//
//  AnimationCurve.swift
//  AnimationDemo
//

import Foundation

enum AnimationCurve: String, CaseIterable, Identifiable {
    case defaultCurve = ".default"
    case linear = ".linear"
    case easeIn = ".easeIn"
    case easeOut = ".easeOut"
    case easeInOut = ".easeInOut"
    case smooth = ".smooth"
    case spring = ".spring"
    case snappy = ".snappy"
    case bouncy = ".bouncy"
    case interpolatingSpring = ".interpolatingSpring"
    case interactiveSpring = ".interactiveSpring"

    var id: String { rawValue }

    var isInteractive: Bool {
        switch self {
        case .interpolatingSpring, .interactiveSpring:
            return true
        default:
            return false
        }
    }

    static var standardCurves: [AnimationCurve] {
        allCases.filter { !$0.isInteractive }
    }

    static var interactiveCurves: [AnimationCurve] {
        allCases.filter { $0.isInteractive }
    }
}
