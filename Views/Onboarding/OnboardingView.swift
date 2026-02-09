import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player

    @State private var currentStep = 0
    @State private var selectedGoals: Set<FitnessGoal> = []
    @State private var selectedLevel: FitnessLevel?
    @State private var selectedStyle: WorkoutStyle?
    @State private var weeklyGoal: Int = 3
    @State private var selectedEquipment: Set<EquipmentAccess> = []
    @State private var selectedFocusAreas: Set<FocusArea> = []
    @State private var selectedPetSpecies: PetSpecies?
    @State private var petName: String = ""

    private var totalSteps: Int {
        // Base steps: Welcome, Auth, Goals, Level, Style, Weekly Goal, Equipment, Pet, Complete = 9
        // Focus step only shows if "Build muscle" is selected = 10
        selectedGoals.contains(.buildMuscle) ? 10 : 9
    }

    private var showFocusStep: Bool {
        selectedGoals.contains(.buildMuscle)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar (hide on complete step)
            if currentStep < totalSteps - 1 {
                HStack(spacing: PixelScale.px(2)) {
                    // Back button
                    if currentStep > 0 {
                        Button(action: goBack) {
                            PixelText("<", size: .medium)
                        }
                        .frame(width: PixelScale.px(6))
                    } else {
                        Spacer()
                            .frame(width: PixelScale.px(6))
                    }

                    // Progress bar
                    PixelProgressBar(
                        progress: Double(currentStep + 1) / Double(totalSteps),
                        segments: totalSteps
                    )

                    // Step indicator
                    PixelText("\(currentStep + 1)/\(totalSteps)", size: .small, color: PixelTheme.textSecondary)
                        .frame(width: PixelScale.px(10))
                }
                .padding(.horizontal, PixelScale.px(2))
                .padding(.top, PixelScale.px(2))
            }

            // Content
            stepContent
                .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .background(PixelTheme.background)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            OnboardingWelcomeStep(
                onContinue: { goToNextStep() }
            )
        case 1:
            OnboardingAuthStep(
                player: player,
                onComplete: { goToNextStep() },
                onRestore: { /* player.hasCompletedOnboarding is already set — ContentView handles transition */ }
            )
        case 2:
            OnboardingGoalsStep(
                selectedGoals: $selectedGoals,
                onContinue: { goToNextStep() }
            )
        case 3:
            OnboardingLevelStep(
                selectedLevel: $selectedLevel,
                onContinue: { goToNextStep() }
            )
        case 4:
            OnboardingStyleStep(
                selectedStyle: $selectedStyle,
                onContinue: { goToNextStep() }
            )
        case 5:
            OnboardingWeeklyGoalStep(
                weeklyGoal: $weeklyGoal,
                onContinue: { goToNextStep() }
            )
        case 6:
            OnboardingEquipmentStep(
                selectedEquipment: $selectedEquipment,
                onContinue: { goToNextStep() },
                onSkip: { goToNextStep() }
            )
        case 7:
            if showFocusStep {
                OnboardingFocusStep(
                    selectedAreas: $selectedFocusAreas,
                    onContinue: { goToNextStep() }
                )
            } else {
                OnboardingPetStep(
                    selectedSpecies: $selectedPetSpecies,
                    petName: $petName,
                    onContinue: { goToNextStep() }
                )
            }
        case 8:
            if showFocusStep {
                OnboardingPetStep(
                    selectedSpecies: $selectedPetSpecies,
                    petName: $petName,
                    onContinue: { goToNextStep() }
                )
            } else {
                OnboardingCompleteStep(
                    playerName: "",
                    petSpecies: selectedPetSpecies,
                    petName: petName,
                    weeklyGoal: weeklyGoal,
                    onComplete: { completeOnboarding() }
                )
            }
        case 9:
            OnboardingCompleteStep(
                playerName: "",
                petSpecies: selectedPetSpecies,
                petName: petName,
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
        player.name = ""  // No user name needed
        player.fitnessGoals = Array(selectedGoals)
        player.fitnessLevel = selectedLevel
        player.workoutStyle = selectedStyle
        player.weeklyWorkoutGoal = weeklyGoal
        player.equipmentAccess = Array(selectedEquipment)
        player.focusAreas = Array(selectedFocusAreas)

        // Create pet (required in Fitogatchi)
        if let species = selectedPetSpecies {
            let trimmedName = petName.trimmingCharacters(in: .whitespaces)
            let pet = Pet(name: trimmedName.isEmpty ? species.displayName : trimmedName, species: species)
            player.pet = pet
            modelContext.insert(pet)
        }

        // Mark onboarding as complete
        player.hasCompletedOnboarding = true

        try? modelContext.save()

        // Sync full profile to CloudKit
        if let appleUserID = player.appleUserID {
            Task {
                try? await CloudKitService.shared.createOrUpdateUserProfile(
                    player: player,
                    appleUserID: appleUserID
                )
            }
        }
    }
}

#Preview {
    OnboardingView(player: Player(name: ""))
        .modelContainer(for: [Player.self, Pet.self], inMemory: true)
}
