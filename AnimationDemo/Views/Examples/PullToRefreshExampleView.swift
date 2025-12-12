//
//  PullToRefreshExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct PullToRefreshExampleView: View {
    @State private var pullOffset: CGFloat = 0
    @State private var isRefreshing = false

    private let example = ExampleType.pullToRefresh
    private let threshold: CGFloat = 80

    var body: some View {
        ExampleCardContainer(example: example) {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer()

                    // Refresh indicator
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                            .frame(width: 44, height: 44)

                        Circle()
                            .trim(from: 0, to: min(pullOffset / threshold, 1.0))
                            .stroke(Color.blue, lineWidth: 4)
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))
                            .rotationEffect(.degrees(pullOffset * 3))

                        if isRefreshing {
                            ProgressView()
                        }
                    }
                    .offset(y: min(pullOffset * 0.5, threshold))
                    .opacity(pullOffset > 10 ? 1 : 0)

                    Spacer()

                    // Content area (fake list)
                    VStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { index in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 50, height: 50)

                                VStack(alignment: .leading, spacing: 6) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 120, height: 12)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(width: 80, height: 10)
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
                    .frame(width: min(geometry.size.width - 40, 300))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                            .overlay(
                                VStack {
                                    Image(systemName: "arrow.down")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                    Text("Pull down")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .opacity(pullOffset > 0 ? 0 : 1)
                            )
                    )
                    .offset(y: min(pullOffset * 0.3, 40))
                    .gesture(pullGesture)

                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
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
                    withAnimation(.interpolatingSpring(stiffness: 150, damping: 12)) {
                        pullOffset = threshold
                    }

                    // Simulate refresh completion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isRefreshing = false
                        withAnimation(.interpolatingSpring(stiffness: 150, damping: 12)) {
                            pullOffset = 0
                        }
                    }
                } else {
                    // Spring back
                    withAnimation(.interpolatingSpring(stiffness: 150, damping: 12)) {
                        pullOffset = 0
                    }
                }
            }
    }
}

#Preview {
    PullToRefreshExampleView()
}
