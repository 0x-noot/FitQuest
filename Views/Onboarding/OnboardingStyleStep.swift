import SwiftUI

struct OnboardingStyleStep: View {
    @Binding var selectedStyle: WorkoutStyle?
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("What's your workout style?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Choose your preferred training type")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.top, 8)

            Spacer()

            // Style options
            VStack(spacing: 12) {
                ForEach(WorkoutStyle.allCases) { style in
                    SelectionCard(
                        title: style.displayName,
                        description: style.description,
                        iconName: style.iconName,
                        isSelected: selectedStyle == style
                    ) {
                        selectedStyle = style
                    }
                }
            }

            Spacer()

            // Continue button
            PrimaryButton("Continue", icon: "arrow.right") {
                onContinue()
            }
            .disabled(selectedStyle == nil)
            .opacity(selectedStyle == nil ? 0.5 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    OnboardingStyleStep(
        selectedStyle: .constant(.balanced)
    ) {}
    .background(Theme.background)
}
