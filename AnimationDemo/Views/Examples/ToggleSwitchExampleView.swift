//
//  ToggleSwitchExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct ToggleSwitchExampleView: View {
    @State private var isOn = false

    private let example = ExampleType.toggleSwitch

    var body: some View {
        ExampleCardContainer(example: example) {
            ZStack {
                Capsule()
                    .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 120, height: 66)

                Circle()
                    .fill(.white)
                    .frame(width: 54, height: 54)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    .offset(x: isOn ? 27 : -27)
            }
            .onTapGesture {
                withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                    isOn.toggle()
                }
            }
        }
    }
}

#Preview {
    ToggleSwitchExampleView()
}
