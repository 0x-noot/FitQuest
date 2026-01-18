import SwiftUI

struct OnboardingGoalsStep: View {
    @Binding var selectedGoals: Set<FitnessGoal>
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("What are your goals?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Select all that apply")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.top, 8)

            // Goals list
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(FitnessGoal.allCases) { goal in
                        MultiSelectCard(
                            title: goal.displayName,
                            description: goal.description,
                            iconName: goal.iconName,
                            isSelected: selectedGoals.contains(goal)
                        ) {
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }
                    }
                }
            }

            // Continue button
            PrimaryButton("Continue", icon: "arrow.right") {
                onContinue()
            }
            .disabled(selectedGoals.isEmpty)
            .opacity(selectedGoals.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    OnboardingGoalsStep(
        selectedGoals: .constant([.buildMuscle])
    ) {}
    .background(Theme.background)
}
