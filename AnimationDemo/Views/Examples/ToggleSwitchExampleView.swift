//
//  ToggleSwitchExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct ToggleSwitchExampleView: View {
    @State private var isOn = false
    @State private var animationType: AnimationTypeOption = .spring
    @State private var parameters: [String: Double] = ["duration": 0.2, "bounce": 0.3]

    private let example = ExampleType.toggleSwitch

    private var simplifiedCode: String {
        """
        import SwiftUI

        struct ToggleSwitchView: View {
            @State private var isOn = false

            var body: some View {
                ZStack {
                    Capsule()
                        .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 60, height: 34)

                    Circle()
                        .fill(.white)
                        .shadow(radius: 2)
                        .frame(width: 28, height: 28)
                        .offset(x: isOn ? 13 : -13)
                }
                .onTapGesture {
                    withAnimation(\(animationType.codeString(with: parameters))) {
                        isOn.toggle()
                    }
                }
            }
        }

        #Preview {
            ToggleSwitchView()
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
            ZStack {
                Capsule()
                    .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 200, height: 110)

                Circle()
                    .fill(.white)
                    .frame(width: 90, height: 90)
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                    .offset(x: isOn ? 45 : -45)
            }
            .onTapGesture {
                withAnimation(animationType.buildAnimation(with: parameters)) {
                    isOn.toggle()
                }
            }
        }
    }
}

#Preview {
    ToggleSwitchExampleView()
}
