//
//  ExampleType.swift
//  AnimationDemo
//

import SwiftUI

enum ExampleType: String, CaseIterable, Identifiable {
    case toggleSwitch = "Toggle Switch"
    case floatingButton = "Floating Button"
    case dragRelease = "Drag & Release"
    case heartReaction = "Heart Reaction"
    case pullToRefresh = "Pull to Refresh"
    case tabBar = "Tab Bar"
    case toastNotification = "Toast Notification"
    case cardStack = "Card Stack"
    case cardFlip = "Card Flip"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .toggleSwitch: return "switch.2"
        case .floatingButton: return "plus.circle.fill"
        case .dragRelease: return "hand.draw"
        case .heartReaction: return "heart.fill"
        case .pullToRefresh: return "arrow.down.circle"
        case .tabBar: return "rectangle.split.3x1"
        case .toastNotification: return "bell.badge"
        case .cardStack: return "square.stack.3d.down.right"
        case .cardFlip: return "rectangle.portrait.rotate"
        }
    }

    var description: String {
        switch self {
        case .toggleSwitch: return "Tap to toggle on/off with spring animation"
        case .floatingButton: return "Tap to expand menu with staggered springs"
        case .dragRelease: return "Drag anywhere, release to spring back"
        case .heartReaction: return "Tap to show a bouncing heart"
        case .pullToRefresh: return "Pull down to trigger refresh animation"
        case .tabBar: return "Tap tabs to animate the selection indicator"
        case .toastNotification: return "Tap to create stacking toast notifications"
        case .cardStack: return "Swipe cards left or right to dismiss"
        case .cardFlip: return "Tap to flip the card and reveal the back"
        }
    }

    var accentColor: Color {
        switch self {
        case .toggleSwitch: return .green
        case .floatingButton: return .orange
        case .dragRelease: return .purple
        case .heartReaction: return .red
        case .pullToRefresh: return .blue
        case .tabBar: return .cyan
        case .toastNotification: return .indigo
        case .cardStack: return .pink
        case .cardFlip: return .teal
        }
    }

    var codeSnippet: String {
        switch self {
        case .toggleSwitch:
            return """
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                isOn.toggle()
            }
            """
        case .floatingButton:
            return """
            withAnimation(.spring(duration: 0.4, bounce: 0.3).delay(Double(index) * 0.05)) {
                isExpanded.toggle()
            }
            """
        case .dragRelease:
            return """
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                dragOffset = .zero
            }
            """
        case .heartReaction:
            return """
            withAnimation(.spring(duration: 0.4, bounce: 0.6)) {
                heartScale = 1.3
            }
            """
        case .pullToRefresh:
            return """
            withAnimation(.interpolatingSpring(stiffness: 150, damping: 12)) {
                pullOffset = 0
            }
            """
        case .tabBar:
            return """
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                selectedTab = index
            }
            """
        case .toastNotification:
            return """
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                toasts.append(newToast)
            }
            """
        case .cardStack:
            return """
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                offset = translation
                rotation = Double(translation.width / 20)
            }
            """
        case .cardFlip:
            return """
            withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
                isFlipped.toggle()
            }
            """
        }
    }
}
