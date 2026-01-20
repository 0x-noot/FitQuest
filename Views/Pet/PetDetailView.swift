import SwiftUI
import SwiftData

struct PetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var pet: Pet
    @Bindable var player: Player

    @State private var showLevelUpConfirm = false
    @State private var showTreatSheet = false
    @State private var showRecoveryConfirm = false
    @State private var recoveryMethod: RecoveryMethod = .workouts

    enum RecoveryMethod {
        case workouts
        case essence
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if pet.isAway {
                        awayStateView
                    } else {
                        activeStateView
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(Theme.background)
            .navigationTitle(pet.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.cardBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
            .sheet(isPresented: $showTreatSheet) {
                TreatSelectionSheet(pet: pet, player: player)
            }
            .alert("Level Up \(pet.name)?", isPresented: $showLevelUpConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Level Up") {
                    let success = PetManager.levelUpPet(pet: pet, player: player)
                    if success {
                        try? modelContext.save()
                    }
                }
            } message: {
                Text("Level up to Level \(pet.level + 1) for \(PetManager.levelUpCost(currentLevel: pet.level)) Essence? Your pet's XP bonus will increase!")
            }
            .alert("Recover \(pet.name)?", isPresented: $showRecoveryConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Recover") {
                    let success: Bool
                    if recoveryMethod == .workouts {
                        success = PetManager.recoverPetWithWorkouts(pet: pet)
                    } else {
                        success = PetManager.recoverPetWithEssence(pet: pet, player: player)
                    }
                    if success {
                        try? modelContext.save()
                    }
                }
            } message: {
                if recoveryMethod == .workouts {
                    Text("Your \(pet.species.displayName) will return with 50% happiness!")
                } else {
                    Text("Spend 150 Essence to bring your \(pet.species.displayName) back with 50% happiness?")
                }
            }
        }
    }

    // MARK: - Active State View

    private var activeStateView: some View {
        VStack(spacing: 24) {
            // Pet display
            petDisplaySection

            // Happiness section
            happinessSection

            // Level & XP Bonus section
            levelSection

            // Feed treats section
            feedSection

            // Species info
            speciesInfoSection

            // Tips
            tipsSection
        }
    }

    private var petDisplaySection: some View {
        VStack(spacing: 16) {
            PetCompanionView(pet: pet, size: 120)

            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("\(pet.species.displayName) • Level \(pet.level)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }

    private var happinessSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Happiness")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                Text("\(Int(pet.happiness))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(pet.mood.color)
            }

            // Happiness bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.elevated)

                    // Fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [pet.mood.color, pet.mood.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (pet.happiness / 100.0))
                }
            }
            .frame(height: 12)

            HStack {
                Text(pet.mood.emoji)
                    .font(.system(size: 14))

                Text(pet.mood.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                Spacer()
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }

    private var levelSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(pet.level)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text("Current XP Bonus")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(xpBonusText)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.primary)

                    if PetManager.hasXPBonus(happiness: pet.happiness) {
                        Text("+10% happiness")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.success)
                    }
                }
            }

            Divider()
                .background(Theme.elevated)

            // Level up button
            let levelUpCost = PetManager.levelUpCost(currentLevel: pet.level)
            let canAfford = player.essenceCurrency >= levelUpCost

            Button {
                showLevelUpConfirm = true
            } label: {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 18))

                    Text("Level Up to \(pet.level + 1)")
                        .font(.system(size: 16, weight: .semibold))

                    Spacer()

                    HStack(spacing: 4) {
                        Text("\(levelUpCost)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                    }
                }
                .foregroundColor(canAfford ? .white : Theme.textMuted)
                .padding(16)
                .background(canAfford ? Theme.primary : Theme.elevated)
                .cornerRadius(12)
            }
            .disabled(!canAfford)
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }

    private var feedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feed Treats")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            Button {
                showTreatSheet = true
            } label: {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.warning)

                    Text("Give Treat")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(16)
                .background(Theme.elevated)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }

    private var speciesInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: pet.species.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(Theme.primary)

                Text(pet.species.displayName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }

            Text(pet.species.description)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textSecondary)
                .lineSpacing(4)

            Divider()
                .background(Theme.elevated)

            VStack(alignment: .leading, spacing: 8) {
                Text("Special Bonus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textMuted)

                switch pet.species {
                case .dragon:
                    BonusRow(
                        icon: "dumbbell.fill",
                        text: "Strength XP",
                        bonus: "+\(bonusPercentage(for: .strength))%",
                        color: Theme.primary
                    )
                case .fox:
                    BonusRow(
                        icon: "figure.run",
                        text: "Cardio XP",
                        bonus: "+\(bonusPercentage(for: .cardio))%",
                        color: Theme.secondary
                    )
                case .turtle:
                    VStack(spacing: 6) {
                        BonusRow(
                            icon: "dumbbell.fill",
                            text: "Strength XP",
                            bonus: "+\(bonusPercentage(for: .strength))%",
                            color: Theme.primary
                        )
                        BonusRow(
                            icon: "figure.run",
                            text: "Cardio XP",
                            bonus: "+\(bonusPercentage(for: .cardio))%",
                            color: Theme.secondary
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.warning)

                Text("Tips")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                TipRow(text: "Happiness decays \(String(format: "%.1f", PetManager.passiveDecayPerDay))% per day")
                TipRow(text: "Work out to restore +\(Int(PetManager.workoutHappinessBoost))% happiness")
                TipRow(text: "Feed treats to boost happiness instantly")
                TipRow(text: "Level up your pet to increase XP bonuses")
                TipRow(text: "Keep happiness ≥90% for +10% XP bonus")
            }
        }
        .padding(16)
        .background(Theme.elevated)
        .cornerRadius(16)
    }

    // MARK: - Away State View

    private var awayStateView: some View {
        VStack(spacing: 24) {
            // Away message
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.textMuted.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: pet.species.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(Theme.textMuted.opacity(0.5))
                }

                VStack(spacing: 8) {
                    Text("\(pet.name) ran away...")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text("Your \(pet.species.displayName) left because happiness hit 0%")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(Theme.cardBackground)
            .cornerRadius(16)

            // Recovery options
            VStack(alignment: .leading, spacing: 16) {
                Text("Recovery Options")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                // Option 1: Complete workouts
                let canRecoverWithWorkouts = PetManager.canRecoverWithWorkouts(pet: pet, player: player)

                Button {
                    recoveryMethod = .workouts
                    showRecoveryConfirm = true
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(canRecoverWithWorkouts ? Theme.success : Theme.textMuted)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Complete 3 Workouts")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.textPrimary)

                                Text("In the last 7 days")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)
                            }

                            Spacer()

                            if canRecoverWithWorkouts {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Theme.success)
                            }
                        }
                    }
                    .padding(16)
                    .background(canRecoverWithWorkouts ? Theme.success.opacity(0.15) : Theme.elevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(canRecoverWithWorkouts ? Theme.success : Color.clear, lineWidth: 2)
                    )
                }
                .disabled(!canRecoverWithWorkouts)

                // Option 2: Pay essence
                let canRecoverWithEssence = PetManager.canRecoverWithEssence(pet: pet, player: player)

                Button {
                    recoveryMethod = .essence
                    showRecoveryConfirm = true
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                                .foregroundColor(canRecoverWithEssence ? Theme.warning : Theme.textMuted)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pay 150 Essence")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.textPrimary)

                                Text("Current: \(player.essenceCurrency) Essence")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)
                            }

                            Spacer()

                            if canRecoverWithEssence {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Theme.warning)
                            }
                        }
                    }
                    .padding(16)
                    .background(canRecoverWithEssence ? Theme.warning.opacity(0.15) : Theme.elevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(canRecoverWithEssence ? Theme.warning : Color.clear, lineWidth: 2)
                    )
                }
                .disabled(!canRecoverWithEssence)
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(16)

            // Info message
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.secondary)

                    Text("Recovery Info")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                }

                Text("After recovery, \(pet.name) will return with 50% happiness. You'll still earn Essence from workouts even while your pet is away!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .lineSpacing(4)
            }
            .padding(16)
            .background(Theme.elevated)
            .cornerRadius(16)
        }
    }

    // MARK: - Helpers

    private var xpBonusText: String {
        let strengthBonus = pet.species.xpMultiplier(for: .strength, petLevel: pet.level)
        let cardioBonus = pet.species.xpMultiplier(for: .cardio, petLevel: pet.level)

        switch pet.species {
        case .dragon:
            let percentage = Int((strengthBonus - 1.0) * 100)
            return "+\(percentage)%"
        case .fox:
            let percentage = Int((cardioBonus - 1.0) * 100)
            return "+\(percentage)%"
        case .turtle:
            let percentage = Int((strengthBonus - 1.0) * 100)
            return "+\(percentage)%"
        }
    }

    private func bonusPercentage(for workoutType: WorkoutType) -> String {
        let multiplier = pet.species.xpMultiplier(for: workoutType, petLevel: pet.level)
        let percentage = (multiplier - 1.0) * 100
        return String(format: "%.1f", percentage)
    }
}

// MARK: - Helper Views

struct BonusRow: View {
    let icon: String
    let text: String
    let bonus: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            Text(bonus)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

struct TipRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textMuted)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    PetDetailView(
        pet: {
            let pet = Pet(name: "Fluffy", species: .dragon)
            pet.happiness = 85
            pet.level = 5
            return pet
        }(),
        player: {
            let p = Player(name: "Test")
            p.essenceCurrency = 250
            return p
        }()
    )
    .preferredColorScheme(.dark)
}
