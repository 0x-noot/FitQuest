import SwiftUI

struct SpeechBubbleView: View {
    let text: String
    let mood: PetMood
    @Binding var isVisible: Bool

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var offsetY: CGFloat = 10

    var body: some View {
        VStack(spacing: 0) {
            // Bubble content
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.cardBackground)
                        .shadow(color: mood.color.opacity(0.2), radius: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(mood.color.opacity(0.3), lineWidth: 1)
                )

            // Speech bubble tail
            Triangle()
                .fill(Theme.cardBackground)
                .frame(width: 16, height: 10)
                .rotationEffect(.degrees(180))
                .offset(y: -1)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .offset(y: offsetY)
        .onAppear {
            showBubble()
        }
        .onTapGesture {
            dismissBubble()
        }
    }

    private func showBubble() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
            offsetY = 0
        }

        // Auto-dismiss after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            dismissBubble()
        }
    }

    private func dismissBubble() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.8
            opacity = 0
            offsetY = -10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isVisible = false
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct PetDialogueOverlay: View {
    let pet: Pet
    @Binding var dialogueText: String?
    @Binding var isVisible: Bool

    var body: some View {
        if let text = dialogueText, isVisible {
            VStack {
                SpeechBubbleView(
                    text: text,
                    mood: pet.mood,
                    isVisible: $isVisible
                )
                .padding(.bottom, 8)
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.background
            .ignoresSafeArea()

        VStack(spacing: 40) {
            SpeechBubbleView(
                text: "ROAR! Let's conquer today!",
                mood: .ecstatic,
                isVisible: .constant(true)
            )

            SpeechBubbleView(
                text: "My leaves are drooping...",
                mood: .sad,
                isVisible: .constant(true)
            )

            SpeechBubbleView(
                text: "*happy zoomies*",
                mood: .happy,
                isVisible: .constant(true)
            )
        }
    }
    .preferredColorScheme(.dark)
}
