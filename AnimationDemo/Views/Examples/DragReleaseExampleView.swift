//
//  DragReleaseExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct DragReleaseExampleView: View {
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var animationType: AnimationTypeOption = .interpolatingSpring
    @State private var parameters: [String: Double] = ["stiffness": 200, "damping": 15]

    private let example = ExampleType.dragRelease

    private var simplifiedCode: String {
        let animCode = animationType.codeString(with: parameters)
        return """
        struct DraggableCircle: View {
            @State private var offset: CGSize = .zero
            @State private var isDragging = false

            var body: some View {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 80, height: 80)
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                offset = value.translation
                            }
                            .onEnded { _ in
                                isDragging = false
                                withAnimation(\(animCode)) {
                                    offset = .zero
                                }
                            }
                    )
            }
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
            GeometryReader { geometry in
                ZStack {
                    // Grid background for visual reference
                    gridBackground

                    // Origin indicator
                    Circle()
                        .stroke(Color.purple.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .frame(width: 100, height: 100)

                    // Draggable object
                    Circle()
                        .fill(Color.purple.gradient)
                        .frame(width: 90, height: 90)
                        .scaleEffect(isDragging ? 1.15 : 1.0)
                        .shadow(color: .purple.opacity(0.4), radius: isDragging ? 20 : 8, y: isDragging ? 10 : 4)
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.interactiveSpring) {
                                        isDragging = true
                                    }
                                    dragOffset = value.translation
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    withAnimation(animationType.buildAnimation(with: parameters)) {
                                        dragOffset = .zero
                                    }
                                }
                        )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    private var gridBackground: some View {
        Canvas { context, size in
            let spacing: CGFloat = 30
            let color = Color.gray.opacity(0.1)

            for x in stride(from: 0, to: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(color), lineWidth: 1)
            }

            for y in stride(from: 0, to: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(color), lineWidth: 1)
            }
        }
    }
}

#Preview {
    DragReleaseExampleView()
}
