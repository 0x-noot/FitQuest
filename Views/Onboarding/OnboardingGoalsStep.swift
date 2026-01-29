import SwiftUI

struct OnboardingGoalsStep: View {
    @Binding var selectedGoals: Set<FitnessGoal>
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            // Header
            VStack(spacing: PixelScale.px(1)) {
                PixelText("YOUR GOALS?", size: .xlarge)
                PixelText("SELECT ALL THAT APPLY", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(.top, PixelScale.px(2))

            // Goals list
            ScrollView {
                VStack(spacing: PixelScale.px(2)) {
                    ForEach(FitnessGoal.allCases) { goal in
                        PixelMultiSelectCard(
                            title: goal.displayName.uppercased(),
                            description: goal.description.uppercased(),
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
                .padding(.horizontal, PixelScale.px(4))
            }

            // Continue button
            PixelButton("CONTINUE >", style: .primary) {
                onContinue()
            }
            .disabled(selectedGoals.isEmpty)
            .opacity(selectedGoals.isEmpty ? 0.5 : 1)
            .padding(.horizontal, PixelScale.px(4))
        }
        .padding(.vertical, PixelScale.px(4))
    }
}

// MARK: - Pixel Multi-Select Card

struct PixelMultiSelectCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PixelScale.px(2)) {
                PixelCheckbox(isChecked: isSelected)

                VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                    PixelText(title, size: .small)
                    PixelText(description, size: .small, color: PixelTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(PixelScale.px(2))
            .background(isSelected ? PixelTheme.gbDark.opacity(0.3) : PixelTheme.cardBackground)
            .pixelOutline()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingGoalsStep(
        selectedGoals: .constant([.buildMuscle])
    ) {}
    .background(PixelTheme.background)
}
