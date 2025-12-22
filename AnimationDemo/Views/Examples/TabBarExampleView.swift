//
//  TabBarExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct TabBarExampleView: View {
    @State private var selectedTab: Int = 0
    @State private var animationType: AnimationTypeOption = .snappy
    @State private var parameters: [String: Double] = ["duration": 0.2, "extraBounce": 0.1]

    private let example = ExampleType.tabBar

    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("magnifyingglass", "Search"),
        ("heart.fill", "Favorites"),
        ("person.fill", "Profile")
    ]

    private var simplifiedCode: String {
        let animCode = animationType.codeString(with: parameters)
        return """
        import SwiftUI

        struct CustomTabBar: View {
            @State private var selectedTab = 0

            let tabs = [("house.fill", "Home"), ("magnifyingglass", "Search"),
                        ("heart.fill", "Favorites"), ("person.fill", "Profile")]
            let tabWidth: CGFloat = 80

            var body: some View {
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \\.offset) { index, tab in
                        Button {
                            withAnimation(\(animCode)) {
                                selectedTab = index
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tab.0)
                                Text(tab.1).font(.caption)
                            }
                            .foregroundStyle(selectedTab == index ? .cyan : .secondary)
                            .frame(width: tabWidth)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 10)
                .background(alignment: .leading) {
                    Capsule()
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: tabWidth - 8, height: 50)
                        .offset(x: CGFloat(selectedTab) * tabWidth + 4)
                }
                .background(Capsule().fill(.gray.opacity(0.1)))
            }
        }

        #Preview {
            CustomTabBar()
        }
        """
    }

    var body: some View {
        ExampleCardContainer(
            example: example,
            animationType: $animationType,
            parameters: $parameters,
            fullCode: simplifiedCode
        ) {
            VStack {
                Spacer()
                tabBar
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var tabBar: some View {
        let tabWidth: CGFloat = 100

        return HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(animationType.buildAnimation(with: parameters)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 26))
                        Text(tab.label)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(selectedTab == index ? example.accentColor : .secondary)
                    .frame(width: tabWidth, height: 70)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(alignment: .leading) {
            // Animated indicator
            RoundedRectangle(cornerRadius: 12)
                .fill(example.accentColor.opacity(0.15))
                .frame(width: tabWidth - 12, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(example.accentColor.opacity(0.3), lineWidth: 1.5)
                )
                .offset(x: CGFloat(selectedTab) * tabWidth + 6)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        )
    }
}

#Preview {
    TabBarExampleView()
}
