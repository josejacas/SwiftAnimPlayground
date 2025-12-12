//
//  PullToRefreshExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct PullToRefreshExampleView: View {
    @State private var pullOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var animationType: AnimationTypeOption = .interpolatingSpring
    @State private var parameters: [String: Double] = ["stiffness": 150, "damping": 12]

    private let example = ExampleType.pullToRefresh
    private let threshold: CGFloat = 80

    private var simplifiedCode: String {
        let animCode = animationType.codeString(with: parameters)
        return """
        struct PullToRefreshView: View {
            @State private var pullOffset: CGFloat = 0
            @State private var isRefreshing = false
            let threshold: CGFloat = 60

            var body: some View {
                VStack {
                    // Refresh indicator
                    ProgressView()
                        .opacity(pullOffset > 20 ? 1 : 0)
                        .offset(y: min(pullOffset * 0.5, threshold))

                    // Your content here
                    Text("Pull me down!")
                        .padding(.top, 40)
                        .offset(y: pullOffset * 0.3)

                    Spacer()
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 && !isRefreshing {
                                pullOffset = value.translation.height * 0.5
                            }
                        }
                        .onEnded { _ in
                            if pullOffset > threshold {
                                isRefreshing = true
                                // Simulate refresh
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    isRefreshing = false
                                    withAnimation(\(animCode)) {
                                        pullOffset = 0
                                    }
                                }
                            } else {
                                withAnimation(\(animCode)) {
                                    pullOffset = 0
                                }
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
            VStack(spacing: 0) {
                // Refresh indicator
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: min(pullOffset / threshold, 1.0))
                        .stroke(Color.blue, lineWidth: 4)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .rotationEffect(.degrees(pullOffset * 3))

                    if isRefreshing {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                }
                .offset(y: min(pullOffset * 0.5, threshold))
                .opacity(pullOffset > 10 ? 1 : 0)

                Spacer()

                // Content area (fake list)
                VStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)

                            VStack(alignment: .leading, spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 140, height: 14)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 100, height: 12)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
                .frame(width: 340)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.05))
                        .overlay(
                            VStack {
                                Image(systemName: "arrow.down")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                                Text("Pull down")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .opacity(pullOffset > 0 ? 0 : 1)
                        )
                )
                .offset(y: min(pullOffset * 0.3, 40))
                .gesture(pullGesture)

                Spacer()
            }
        }
    }

    private var pullGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 && !isRefreshing {
                    pullOffset = value.translation.height * 0.6
                }
            }
            .onEnded { _ in
                if pullOffset > threshold && !isRefreshing {
                    // Trigger refresh
                    isRefreshing = true
                    withAnimation(animationType.buildAnimation(with: parameters)) {
                        pullOffset = threshold
                    }

                    // Simulate refresh completion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isRefreshing = false
                        withAnimation(animationType.buildAnimation(with: parameters)) {
                            pullOffset = 0
                        }
                    }
                } else {
                    // Spring back
                    withAnimation(animationType.buildAnimation(with: parameters)) {
                        pullOffset = 0
                    }
                }
            }
    }
}

#Preview {
    PullToRefreshExampleView()
}
