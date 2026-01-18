import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player

    @State private var currentStep = 0
    @State private var name: String = ""
    @State private var character = CharacterAppearance()
    @State private var selectedGoals: Set<FitnessGoal> = []
    @State private var selectedLevel: FitnessLevel?
    @State private var selectedStyle: WorkoutStyle?
    @State private var weeklyGoal: Int = 3
    @State private var selectedEquipment: Set<EquipmentAccess> = []
    @State private var selectedFocusAreas: Set<FocusArea> = []

    private var totalSteps: Int {
        // Base steps: Welcome, Goals, Level, Style, Weekly Goal, Equipment, Character, Complete = 8
        // Focus step only shows if "Build muscle" is selected
        selectedGoals.contains(.buildMuscle) ? 9 : 8
    }

    private var showFocusStep: Bool {
        selectedGoals.contains(.buildMuscle)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar (hide on complete step)
            if currentStep < totalSteps - 1 {
                HStack {
                    // Back button
                    if currentStep > 0 {
                        Button(action: goBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                                .frame(width: 44, height: 44)
                        }
                    } else {
                        Spacer()
                            .frame(width: 44)
                    }

                    OnboardingProgressBar(
                        currentStep: currentStep + 1,
                        totalSteps: totalSteps
                    )

                    // Step indicator
                    Text("\(currentStep + 1)/\(totalSteps)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                        .frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            // Content
            stepContent
                .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .background(Theme.background)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            OnboardingWelcomeStep(
                name: $name,
                character: $character,
                onContinue: { goToNextStep() }
            )
        case 1:
            OnboardingGoalsStep(
                selectedGoals: $selectedGoals,
                onContinue: { goToNextStep() }
            )
        case 2:
            OnboardingLevelStep(
                selectedLevel: $selectedLevel,
                onContinue: { goToNextStep() }
            )
        case 3:
            OnboardingStyleStep(
                selectedStyle: $selectedStyle,
                onContinue: { goToNextStep() }
            )
        case 4:
            OnboardingWeeklyGoalStep(
                weeklyGoal: $weeklyGoal,
                onContinue: { goToNextStep() }
            )
        case 5:
            OnboardingEquipmentStep(
                selectedEquipment: $selectedEquipment,
                onContinue: { goToNextStep() },
                onSkip: { goToNextStep() }
            )
        case 6:
            if showFocusStep {
                OnboardingFocusStep(
                    selectedAreas: $selectedFocusAreas,
                    onContinue: { goToNextStep() }
                )
            } else {
                OnboardingCharacterStep(
                    character: $character,
                    onContinue: { goToNextStep() }
                )
            }
        case 7:
            if showFocusStep {
                OnboardingCharacterStep(
                    character: $character,
                    onContinue: { goToNextStep() }
                )
            } else {
                OnboardingCompleteStep(
                    playerName: name,
                    character: character,
                    weeklyGoal: weeklyGoal,
                    onComplete: { completeOnboarding() }
                )
            }
        case 8:
            OnboardingCompleteStep(
                playerName: name,
                character: character,
                weeklyGoal: weeklyGoal,
                onComplete: { completeOnboarding() }
            )
        default:
            EmptyView()
        }
    }

    private func goToNextStep() {
        withAnimation {
            currentStep += 1
        }
    }

    private func goBack() {
        withAnimation {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }

    private func completeOnboarding() {
        // Save all onboarding data to player
        player.name = name.trimmingCharacters(in: .whitespaces)
        player.fitnessGoals = Array(selectedGoals)
        player.fitnessLevel = selectedLevel
        player.workoutStyle = selectedStyle
        player.weeklyWorkoutGoal = weeklyGoal
        player.equipmentAccess = Array(selectedEquipment)
        player.focusAreas = Array(selectedFocusAreas)

        // Update character
        if let existingCharacter = player.character {
            existingCharacter.bodyType = character.bodyType
            existingCharacter.skinTone = character.skinTone
            existingCharacter.hairStyle = character.hairStyle
            existingCharacter.hairColor = character.hairColor
        } else {
            player.character = character
            modelContext.insert(character)
        }

        // Mark onboarding as complete
        player.hasCompletedOnboarding = true

        try? modelContext.save()
    }
}

#Preview {
    OnboardingView(player: Player(name: ""))
        .modelContainer(for: [Player.self, CharacterAppearance.self], inMemory: true)
}
