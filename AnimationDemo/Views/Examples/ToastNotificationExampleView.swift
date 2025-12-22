//
//  ToastNotificationExampleView.swift
//  AnimationDemo
//

import SwiftUI

struct Toast: Identifiable {
    let id = UUID()
    let message: String
    let icon: String
    let color: Color
}

struct ToastNotificationExampleView: View {
    @State private var toasts: [Toast] = []
    @State private var animationType: AnimationTypeOption = .smooth
    @State private var parameters: [String: Double] = ["duration": 0.3, "bounce": 0.0]

    private let example = ExampleType.toastNotification
    private let maxToasts = 5

    private let sampleMessages: [(String, String, Color)] = [
        ("Message sent", "paperplane.fill", .blue),
        ("File uploaded", "arrow.up.doc.fill", .green),
        ("Download complete", "arrow.down.circle.fill", .purple),
        ("New notification", "bell.fill", .orange),
        ("Saved to favorites", "heart.fill", .pink)
    ]

    private var simplifiedCode: String {
        let animCode = animationType.codeString(with: parameters)
        return """
        import SwiftUI

        struct Toast: Identifiable {
            let id = UUID()
            let message: String
            let icon: String
            let color: Color
        }

        struct ToastDemoView: View {
            @State private var toasts: [Toast] = []

            var body: some View {
                ZStack(alignment: .topTrailing) {
                    // Add button
                    Button("Add Toast") { addToast() }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Toast stack
                    ForEach(Array(toasts.prefix(5).enumerated().reversed()), id: \\.element.id) { index, toast in
                        ToastCard(toast: toast)
                            .offset(y: CGFloat(index) * 8)
                            .scaleEffect(1.0 - CGFloat(index) * 0.03, anchor: .topTrailing)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    .padding()
                }
            }

            func addToast() {
                let toast = Toast(message: "New notification", icon: "bell.fill", color: .orange)
                withAnimation(\(animCode)) {
                    toasts.insert(toast, at: 0)
                    if toasts.count > 5 { toasts.removeLast() }
                }
                // Auto-dismiss
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(3))
                    withAnimation(\(animCode)) {
                        toasts.removeAll { $0.id == toast.id }
                    }
                }
            }
        }

        struct ToastCard: View {
            let toast: Toast

            var body: some View {
                HStack(spacing: 12) {
                    Image(systemName: toast.icon)
                        .foregroundStyle(toast.color)
                    Text(toast.message)
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.background).shadow(radius: 8))
            }
        }

        #Preview {
            ToastDemoView()
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
                // Add toast button
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            addToast()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                Text("Show Toast")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(example.accentColor.gradient)
                                    .shadow(color: example.accentColor.opacity(0.4), radius: 8, y: 4)
                            )
                        }
                        .buttonStyle(.plain)

                        if !toasts.isEmpty {
                            Button {
                                clearAllToasts()
                            } label: {
                                Text("Clear All")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color(nsColor: .controlBackgroundColor))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 24)
                }

                // Toast stack (top right)
                VStack {
                    HStack {
                        Spacer()
                        toastStack
                            .padding(.top, 16)
                            .padding(.trailing, 16)
                    }
                    Spacer()
                }
            }
        }
    }

    private var toastStack: some View {
        ZStack(alignment: .topTrailing) {
            ForEach(Array(toasts.prefix(maxToasts).enumerated().reversed()), id: \.element.id) { index, toast in
                ToastCard(toast: toast)
                    .offset(y: CGFloat(index) * 8)
                    .scaleEffect(1.0 - CGFloat(index) * 0.03, anchor: .topTrailing)
                    .zIndex(Double(maxToasts - index))
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        )
                    )
            }
        }
    }

    private func addToast() {
        let sample = sampleMessages.randomElement()!
        let toast = Toast(message: sample.0, icon: sample.1, color: sample.2)

        withAnimation(animationType.buildAnimation(with: parameters)) {
            toasts.insert(toast, at: 0)
        }

        // Remove oldest if over limit
        if toasts.count > maxToasts {
            withAnimation(animationType.buildAnimation(with: parameters)) {
                toasts.removeLast()
            }
        }

        // Auto-dismiss after delay
        let toastId = toast.id
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(4.0))
            withAnimation(animationType.buildAnimation(with: parameters)) {
                toasts.removeAll { $0.id == toastId }
            }
        }
    }

    private func clearAllToasts() {
        withAnimation(animationType.buildAnimation(with: parameters)) {
            toasts.removeAll()
        }
    }
}

struct ToastCard: View {
    let toast: Toast

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: toast.icon)
                .font(.system(size: 24))
                .foregroundStyle(toast.color)
                .frame(width: 32)

            Text(toast.message)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)

            Spacer(minLength: 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(toast.color.opacity(0.25), lineWidth: 1.5)
        )
    }
}

#Preview {
    ToastNotificationExampleView()
}
