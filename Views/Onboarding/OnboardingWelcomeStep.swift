import SwiftUI

struct OnboardingWelcomeStep: View {
    @Binding var name: String
    @Binding var character: CharacterAppearance
    let onContinue: () -> Void

    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Character preview
            CharacterDisplayView(appearance: character, size: 140)
                .padding(.bottom, 8)

            // Title
            VStack(spacing: 8) {
                Text("Welcome to FitQuest!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Your fitness journey starts here")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }

            // Name input
            VStack(alignment: .leading, spacing: 8) {
                Text("What should we call you?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)

                TextField("Your name", text: $name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.textPrimary)
                    .padding(16)
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                            onContinue()
                        }
                    }
            }
            .padding(.top, 16)

            Spacer()

            // Continue button
            PrimaryButton("Continue", icon: "arrow.right") {
                onContinue()
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
    }
}

#Preview {
    OnboardingWelcomeStep(
        name: .constant(""),
        character: .constant(CharacterAppearance())
    ) {}
    .background(Theme.background)
}
