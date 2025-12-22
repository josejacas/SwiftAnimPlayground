//
//  CurveCreatorView.swift
//  AnimationDemo
//

import SwiftUI

struct CurveCreatorView: View {
    @State private var curve = CustomCurve.easeInOut
    @State private var animationType: AnimationType = .scale
    @State private var demoShape: DemoShape = .roundedRect
    @State private var holdDuration: Double = 0.8
    @State private var isDragging = false
    @State private var restartTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            // Top controls bar (same as Playground/Compare)
            GlobalControlsBar(
                animationType: $animationType,
                demoShape: $demoShape,
                duration: $curve.duration,
                holdDuration: $holdDuration
            )
            .padding()

            // Main content
            HStack(spacing: 0) {
                Spacer()
                // Left side: Preview + Editor
                VStack(spacing: 12) {
                    // Live preview
                    CurvePreviewAnimation(
                        curve: curve,
                        animationType: animationType,
                        demoShape: demoShape,
                        isDragging: isDragging,
                        restartTrigger: restartTrigger
                    )
                    .padding(.top, 30)
                    .id(restartTrigger)

                    // Interactive curve editor
                    InteractiveCurveEditor(
                        p1: $curve.p1,
                        p2: $curve.p2,
                        isDragging: $isDragging,
                        size: CGSize(width: 440, height: 320)
                    )

                    // Coordinate display for fine-tuning
                    CurveCoordinateDisplay(p1: $curve.p1, p2: $curve.p2)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)

                Divider()

                // Right side: Presets + Code Export
                VStack(spacing: 16) {
                    // Presets section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Presets")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal)

                        CurvePresetPicker(
                            selectedCurve: $curve,
                            onPresetSelected: {
                                restartTrigger += 1
                            }
                        )
                        .frame(maxHeight: 400)
                    }

                    Divider()

                    // Code export section
                    CurveCodeExport(curve: curve)
                        .padding(.horizontal)

                    // Limitation note
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 11))
                        Text("For bounce/spring effects with multiple oscillations, use Spring animations in the Playground.")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.vertical)
                .frame(minWidth: 280, maxWidth: 320)
                .background(Color(nsColor: .windowBackgroundColor))
                
                Spacer()
            }
        }
    }

    // MARK: - Actions

    private func resetToDefault() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            curve = CustomCurve.easeInOut
        }
    }
}

#Preview {
    CurveCreatorView()
        .frame(width: 900, height: 700)
}
