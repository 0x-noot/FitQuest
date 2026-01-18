import SwiftUI

struct OnboardingLevelStep: View {
    @Binding var selectedLevel: FitnessLevel?
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("What's your fitness level?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Be honest - we'll tailor your experience")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.top, 8)

            Spacer()

            // Level options
            VStack(spacing: 12) {
                ForEach(FitnessLevel.allCases) { level in
                    SelectionCard(
                        title: level.displayName,
                        description: level.description,
                        iconName: level.iconName,
                        isSelected: selectedLevel == level
                    ) {
                        selectedLevel = level
                    }
                }
            }

            Spacer()

            // Continue button
            PrimaryButton("Continue", icon: "arrow.right") {
                onContinue()
            }
            .disabled(selectedLevel == nil)
            .opacity(selectedLevel == nil ? 0.5 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    OnboardingLevelStep(
        selectedLevel: .constant(.intermediate)
    ) {}
    .background(Theme.background)
}
