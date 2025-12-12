//
//  ContentView.swift
//  AnimationDemo
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMode: AppMode = .playground

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            switch selectedMode {
            case .playground:
                PlaygroundView()
            case .compare:
                CompareView()
            case .examples:
                ExamplesView()
            }
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(selection: $selectedMode) {
                ForEach(AppMode.allCases) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
    }
}

#Preview {
    ContentView()
}
