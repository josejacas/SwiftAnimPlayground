//
//  InteractiveCodeEditor.swift
//  AnimationDemo
//

import SwiftUI
import AppKit

struct InteractiveCodeEditor: View {
    @Binding var animationType: AnimationTypeOption
    @Binding var parameters: [String: Double]
    let accentColor: Color
    var suffix: String = ""

    @State private var editingParameter: String? = nil
    @State private var editText: String = ""

    var body: some View {
        VStack(spacing: 12) {
            // Interactive code line
            HStack(spacing: 0) {
                Text("withAnimation(")
                    .foregroundStyle(.secondary)

                AnimationTypePicker(
                    selectedType: $animationType,
                    parameters: $parameters,
                    accentColor: accentColor,
                    onOpen: { editingParameter = nil }
                )

                Text("(")
                    .foregroundStyle(.secondary)

                // Parameter values
                ForEach(Array(animationType.parameters.enumerated()), id: \.element.name) { index, paramDef in
                    if index > 0 {
                        Text(", ")
                            .foregroundStyle(.secondary)
                    }

                    Text("\(paramDef.name): ")
                        .foregroundStyle(.secondary)

                    parameterValue(for: paramDef)
                }

                Text("))")
                    .foregroundStyle(.secondary)

                if !suffix.isEmpty {
                    Text(suffix)
                        .foregroundStyle(.secondary)
                }

                Text(" { ... }")
                    .foregroundStyle(.secondary)

                Spacer()

                // Copy button
                CopyButton(text: fullCodeString)
            }
            .font(.system(.body, design: .monospaced))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(10)
            .contentShape(Rectangle())
            .onTapGesture {
                // Dismiss editing when tapping on background
                if editingParameter != nil {
                    commitCurrentEdit()
                }
            }
        }
    }

    private func commitCurrentEdit() {
        if let paramName = editingParameter,
           let paramDef = animationType.parameters.first(where: { $0.name == paramName }),
           let newValue = Double(editText) {
            let clamped = min(max(newValue, paramDef.range.lowerBound), paramDef.range.upperBound)
            parameters[paramName] = clamped
        }
        editingParameter = nil
    }

    @ViewBuilder
    private func parameterValue(for paramDef: ParameterDefinition) -> some View {
        let isEditing = editingParameter == paramDef.name
        let value = parameters[paramDef.name] ?? paramDef.defaultValue
        let formattedValue = String(format: "%.\(paramDef.formatDecimals)f", value)

        if isEditing {
            InlineTextField(
                text: $editText,
                onCommit: {
                    if let newValue = Double(editText) {
                        let clamped = min(max(newValue, paramDef.range.lowerBound), paramDef.range.upperBound)
                        parameters[paramDef.name] = clamped
                    }
                    editingParameter = nil
                },
                onCancel: {
                    editingParameter = nil
                }
            )
            .frame(width: 50, height: 22)
            .background(Color.white)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(accentColor, lineWidth: 1.5)
            )
        } else {
            Text(formattedValue)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(accentColor.opacity(0.15))
                .foregroundStyle(accentColor)
                .cornerRadius(4)
                .onTapGesture {
                    editText = formattedValue
                    editingParameter = paramDef.name
                }
        }
    }

    private var fullCodeString: String {
        "withAnimation(\(animationType.codeString(with: parameters))\(suffix)) {\n    // your code\n}"
    }
}

struct AnimationTypePicker: View {
    @Binding var selectedType: AnimationTypeOption
    @Binding var parameters: [String: Double]
    let accentColor: Color
    var onOpen: () -> Void = {}

    var body: some View {
        Menu {
            ForEach(AnimationTypeOption.allCases) { type in
                Button(type.displayName) {
                    selectedType = type
                    parameters = type.defaultParameters
                }
            }
        } label: {
            Text(selectedType.displayName)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(accentColor.opacity(0.2))
                .foregroundStyle(accentColor)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .onTapGesture {
            onOpen()
        }
    }
}

struct InlineTextField: NSViewRepresentable {
    @Binding var text: String
    var onCommit: () -> Void
    var onCancel: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.isBordered = false
        textField.drawsBackground = false
        textField.alignment = .center
        textField.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .medium)
        textField.focusRingType = .none
        textField.stringValue = text

        // Store reference for later
        context.coordinator.textField = textField

        // Add click monitor to detect clicks outside
        context.coordinator.setupClickMonitor()

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        // Only do initial setup once
        if !context.coordinator.didInitialFocus {
            context.coordinator.didInitialFocus = true

            // Use async to ensure the view is fully in the hierarchy
            DispatchQueue.main.async {
                guard let window = nsView.window else { return }

                // Make first responder
                window.makeFirstResponder(nsView)

                // Select all after a brief moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    if let editor = nsView.currentEditor() {
                        editor.selectAll(nil)
                    }
                }
            }
        }
    }

    static func dismantleNSView(_ nsView: NSTextField, coordinator: Coordinator) {
        coordinator.removeClickMonitor()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: InlineTextField
        var didInitialFocus = false
        var didCommit = false
        weak var textField: NSTextField?
        var clickMonitor: Any?

        init(_ parent: InlineTextField) {
            self.parent = parent
        }

        func setupClickMonitor() {
            clickMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
                guard let self = self, let textField = self.textField else { return event }

                // Check if click is outside the text field
                let locationInTextField = textField.convert(event.locationInWindow, from: nil)
                if !textField.bounds.contains(locationInTextField) {
                    // Click is outside - commit and resign
                    if !self.didCommit {
                        self.didCommit = true
                        DispatchQueue.main.async {
                            self.parent.onCommit()
                        }
                    }
                }
                return event
            }
        }

        func removeClickMonitor() {
            if let monitor = clickMonitor {
                NSEvent.removeMonitor(monitor)
                clickMonitor = nil
            }
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            parent.text = textField.stringValue
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            // Commit when focus is lost
            if !didCommit {
                didCommit = true
                parent.onCommit()
            }
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if !didCommit {
                    didCommit = true
                    parent.onCommit()
                }
                return true
            }
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                didCommit = true
                parent.onCancel()
                return true
            }
            return false
        }

        deinit {
            removeClickMonitor()
        }
    }
}

struct CopyButton: View {
    let text: String
    @State private var copied = false

    var body: some View {
        Button {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            copied = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                copied = false
            }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 14))
                .foregroundStyle(copied ? .green : .secondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Copy code")
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var animationType: AnimationTypeOption = .spring
        @State private var parameters: [String: Double] = ["duration": 0.4, "bounce": 0.3]

        var body: some View {
            InteractiveCodeEditor(
                animationType: $animationType,
                parameters: $parameters,
                accentColor: .orange
            )
            .padding()
        }
    }

    return PreviewWrapper()
}
