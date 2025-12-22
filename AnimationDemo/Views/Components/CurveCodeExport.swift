//
//  CurveCodeExport.swift
//  AnimationDemo
//

import SwiftUI
import AppKit

struct CurveCodeExport: View {
    let curve: CustomCurve
    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Generated Code")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            // Code display
            VStack(alignment: .leading, spacing: 0) {
                Text(curve.fullCodeString())
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            // Copy button
            HStack {
                Spacer()

                Button(action: copyCode) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11))
                        Text(showCopied ? "Copied!" : "Copy Code")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(showCopied ? .green : .accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(curve.fullCodeString(), forType: .string)

        withAnimation(.easeInOut(duration: 0.2)) {
            showCopied = true
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeInOut(duration: 0.2)) {
                showCopied = false
            }
        }
    }
}

// MARK: - Coordinate Display

struct CurveCoordinateDisplay: View {
    @Binding var p1: CGPoint
    @Binding var p2: CGPoint

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Control Points")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            HStack(spacing: 16) {
                // P1 coordinates
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("P1")
                            .font(.system(size: 11, weight: .semibold))
                    }

                    HStack(spacing: 8) {
                        CoordinateField(label: "X", value: $p1.x)
                        CoordinateField(label: "Y", value: $p1.y, allowNegative: true)
                    }
                }

                Divider()
                    .frame(height: 50)

                // P2 coordinates
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 8, height: 8)
                        Text("P2")
                            .font(.system(size: 11, weight: .semibold))
                    }

                    HStack(spacing: 8) {
                        CoordinateField(label: "X", value: $p2.x)
                        CoordinateField(label: "Y", value: $p2.y, allowNegative: true)
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CoordinateField: View {
    let label: String
    @Binding var value: CGFloat
    var allowNegative: Bool = false

    @FocusState private var isFocused: Bool
    @State private var textValue: String = ""

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)

            TextField("", text: $textValue)
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 50)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onAppear {
                    textValue = String(format: "%.2f", value)
                }
                .onChange(of: value) { _, newValue in
                    if !isFocused {
                        textValue = String(format: "%.2f", newValue)
                    }
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused {
                        // Parse and validate on blur
                        if let parsed = Double(textValue) {
                            let minVal = allowNegative ? -1.0 : 0.0
                            let maxVal = allowNegative ? 2.0 : 1.0
                            value = CGFloat(max(minVal, min(maxVal, parsed)))
                        }
                        textValue = String(format: "%.2f", value)
                    }
                }
                .onSubmit {
                    isFocused = false
                }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CurveCodeExport(curve: .easeInOut)
            .frame(width: 300)

        CurveCoordinateDisplay(
            p1: .constant(CGPoint(x: 0.42, y: 0.0)),
            p2: .constant(CGPoint(x: 0.58, y: 1.0))
        )
        .frame(width: 300)
    }
    .padding()
}
