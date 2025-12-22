//
//  ExamplesView.swift
//  AnimationDemo
//

import SwiftUI

struct ExamplesView: View {
    @State private var selectedExample: ExampleType = .toggleSwitch

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            sidebar

            Divider()

            // Main content area
            exampleContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.04))
        }
        .frame(minWidth: 800, minHeight: 500)
    }

    private var sidebar: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(ExampleType.allCases) { example in
                    SidebarRow(
                        example: example,
                        isSelected: selectedExample == example
                    )
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                            selectedExample = example
                        }
                    }
                }
            }
            .padding(12)
        }
        .frame(width: 220)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var exampleContent: some View {
        switch selectedExample {
        case .toggleSwitch:
            ToggleSwitchExampleView()
        case .floatingButton:
            FloatingButtonExampleView()
        case .dragRelease:
            DragReleaseExampleView()
        case .heartReaction:
            HeartReactionExampleView()
        case .pullToRefresh:
            PullToRefreshExampleView()
        case .tabBar:
            TabBarExampleView()
        case .toastNotification:
            ToastNotificationExampleView()
        case .cardStack:
            CardStackExampleView()
        case .cardFlip:
            CardFlipExampleView()
        }
    }
}

// MARK: - Sidebar Row

private struct SidebarRow: View {
    let example: ExampleType
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: example.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? .white : example.accentColor)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? example.accentColor : example.accentColor.opacity(0.15))
                )

            Text(example.rawValue)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .primary : .secondary)

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
        )
        .contentShape(Rectangle())
    }
}

#Preview {
    ExamplesView()
}
