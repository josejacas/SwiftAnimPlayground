//
//  FloatingButtonExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct FloatingButtonExampleView: View {
    @State private var isExpanded = false
    @State private var animationType: AnimationTypeOption = .snappy
    @State private var parameters: [String: Double] = ["duration": 0.3, "extraBounce": 0.3]
    @State private var staggerDelay: Double = 0.05

    private let example = ExampleType.floatingButton

    private let menuItems: [(icon: String, color: Color, label: String)] = [
        ("camera.fill", .blue, "Camera"),
        ("photo.fill", .green, "Photos"),
        ("doc.fill", .purple, "Files"),
        ("mic.fill", .pink, "Audio")
    ]

    private var simplifiedCode: String {
        let animCode = animationType.codeString(with: parameters)
        let stagger = String(format: "%.2f", staggerDelay)
        return """
        import SwiftUI

        struct FloatingActionButton: View {
            @State private var isExpanded = false

            let menuItems = ["camera.fill", "photo.fill", "doc.fill", "mic.fill"]

            var body: some View {
                ZStack {
                    // Menu items
                    ForEach(Array(menuItems.enumerated()), id: \\.offset) { index, icon in
                        menuButton(icon: icon, index: index)
                    }

                    // Main button
                    Button {
                        withAnimation(\(animCode)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundStyle(.white)
                                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                            )
                    }
                    .buttonStyle(.borderless)
                }
            }

            func menuButton(icon: String, index: Int) -> some View {
                let angle = -150.0 + Double(index) * 40.0
                let distance: CGFloat = isExpanded ? 100 : 0
                let radians = angle * .pi / 180

                return Button { isExpanded = false } label: {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: icon).foregroundStyle(.white))
                }
                .offset(x: cos(radians) * distance, y: sin(radians) * distance)
                .scaleEffect(isExpanded ? 1 : 0.3)
                .opacity(isExpanded ? 1 : 0)
                .animation(\(animCode).delay(Double(index) * \(stagger)), value: isExpanded)
                .buttonStyle(.borderless)
            }
        }

        #Preview {
            FloatingActionButton()
        }
        """
    }

    var body: some View {
        ExampleCardContainer(
            example: example,
            animationType: $animationType,
            parameters: $parameters,
            codeSuffix: ".delay(i * \(String(format: "%.2f", staggerDelay)))",
            fullCode: simplifiedCode
        ) {
            VStack {
                Spacer()

                ZStack {
                    // Menu items in a circular fan
                    ForEach(Array(menuItems.enumerated()), id: \.offset) { index, item in
                        menuItemView(icon: item.icon, color: item.color, index: index)
                    }

                    // Main FAB button
                    mainButton
                }

                Spacer()

                // Stagger delay control
                HStack(spacing: 8) {
                    Text("stagger:")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Slider(value: $staggerDelay, in: 0.0...0.15)
                        .frame(width: 80)
                        .tint(.orange)
                    Text(String(format: "%.2f", staggerDelay))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(width: 35)
                }
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var mainButton: some View {
        Button {
            withAnimation(animationType.buildAnimation(with: parameters)) {
                isExpanded.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.orange.gradient)
                    .frame(width: 70, height: 70)
                    .shadow(color: .orange.opacity(0.4), radius: isExpanded ? 15 : 8, y: isExpanded ? 8 : 4)

                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func menuItemView(icon: String, color: Color, index: Int) -> some View {
        // Fan out in a semi-circle above the button
        // Angles from -135° to -45° (upper arc)
        let totalItems = menuItems.count
        let startAngle: Double = -150
        let endAngle: Double = -30
        let angleStep = (endAngle - startAngle) / Double(totalItems - 1)
        let angle = startAngle + Double(index) * angleStep

        let distance: CGFloat = isExpanded ? 130 : 0
        let radians = angle * .pi / 180
        let delay = Double(index) * staggerDelay

        Button {
            withAnimation(animationType.buildAnimation(with: parameters)) {
                isExpanded = false
            }
        } label: {
            ZStack {
                Circle()
                    .fill(color.gradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: color.opacity(0.4), radius: isExpanded ? 10 : 4, y: isExpanded ? 5 : 2)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .offset(
            x: cos(radians) * distance,
            y: sin(radians) * distance
        )
        .scaleEffect(isExpanded ? 1 : 0.3)
        .opacity(isExpanded ? 1 : 0)
        .rotationEffect(.degrees(isExpanded ? 0 : 180))
        .animation(
            animationType.buildAnimation(with: parameters)
            .delay(isExpanded ? delay : (Double(menuItems.count - 1 - index) * staggerDelay)),
            value: isExpanded
        )
    }
}

#Preview {
    FloatingButtonExampleView()
}
