//
//  ExampleCardContainer.swift
//  AnimationDemo
//

import SwiftUI

struct ExampleCardContainer<Content: View>: View {
    let example: ExampleType
    let content: () -> Content

    @State private var showCopied = false

    var body: some View {
        VStack(spacing: 20) {
            // Title and description
            VStack(spacing: 8) {
                Text(example.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(example.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Interactive animation area
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(example.accentColor.opacity(0.05))
                )

            // Code preview
            codePreviewButton
        }
        .padding(24)
        .background(cardBackground)
    }

    private var codePreviewButton: some View {
        Button {
            copyCode()
        } label: {
            HStack {
                Text(showCopied ? "Copied!" : example.codeSnippet)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(showCopied ? .green : .secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Image(systemName: showCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(showCopied ? .green : .secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.background)
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(example.accentColor.opacity(0.15), lineWidth: 1)
            )
    }

    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(example.codeSnippet, forType: .string)
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopied = false
        }
    }
}
