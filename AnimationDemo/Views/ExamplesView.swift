//
//  ExamplesView.swift
//  AnimationDemo
//

import SwiftUI

struct ExamplesView: View {
    @State private var selectedExample: ExampleType = .toggleSwitch

    var body: some View {
        VStack(spacing: 24) {
            // Example picker
            Picker("", selection: $selectedExample) {
                ForEach(ExampleType.allCases) { example in
                    Text(example.rawValue).tag(example)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 700)

            // Selected example
            exampleContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(32)
        .frame(minWidth: 600, minHeight: 500)
        .background(Color.gray.opacity(0.04))
    }

    @ViewBuilder
    private var exampleContent: some View {
        switch selectedExample {
        case .toggleSwitch:
            ToggleSwitchExampleView()
        case .cardSwipe:
            CardSwipeExampleView()
        case .dragRelease:
            DragReleaseExampleView()
        case .heartReaction:
            HeartReactionExampleView()
        case .pullToRefresh:
            PullToRefreshExampleView()
        }
    }
}

#Preview {
    ExamplesView()
}
