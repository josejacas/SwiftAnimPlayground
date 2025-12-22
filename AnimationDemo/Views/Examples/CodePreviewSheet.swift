//
//  CodePreviewSheet.swift
//  AnimationDemo
//

import SwiftUI

struct CodePreviewSheet: View {
    let title: String
    let code: String
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.gray.opacity(0.1))

            // Code view
            ScrollView {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(nsColor: .textBackgroundColor))

            // Footer with copy button
            HStack {
                Text("Paste this into a new SwiftUI file to try it out")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                    copied = true
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(2))
                        copied = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy Code")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(copied ? Color.green : Color.accentColor)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .frame(width: 600, height: 500)
    }
}

struct ViewCodeButton: View {
    let title: String
    let code: String
    @State private var showingSheet = false

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                Text("View Code")
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingSheet) {
            CodePreviewSheet(title: title, code: code)
        }
    }
}

#Preview {
    CodePreviewSheet(
        title: "Toggle Switch Example",
        code: """
        struct ToggleSwitchView: View {
            @State private var isOn = false

            var body: some View {
                ZStack {
                    Capsule()
                        .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 60, height: 34)

                    Circle()
                        .fill(.white)
                        .frame(width: 28, height: 28)
                        .offset(x: isOn ? 13 : -13)
                }
                .onTapGesture {
                    withAnimation(.spring(duration: 0.4, bounce: 0.3)) {
                        isOn.toggle()
                    }
                }
            }
        }
        """
    )
}
