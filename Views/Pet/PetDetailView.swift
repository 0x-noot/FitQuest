import SwiftUI
import SwiftData

struct PetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var pet: Pet
    @Bindable var player: Player

    @State private var showTreatSheet = false
    @State private var showRecoveryConfirm = false
    @State private var recoveryMethod: RecoveryMethod = .workouts
    @State private var showAccessoryShop = false

    enum RecoveryMethod {
        case workouts
        case essence
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    PixelText("DONE", size: .small)
                }

                Spacer()

                PixelText(pet.name.uppercased(), size: .medium)

                Spacer()

                // Spacer for balance
                PixelText("    ", size: .small)
            }
            .padding(.horizontal, PixelScale.px(2))
            .padding(.vertical, PixelScale.px(2))
            .background(PixelTheme.gbDark)

            Rectangle()
                .fill(PixelTheme.border)
                .frame(height: PixelScale.px(1))

            // Content
            ScrollView {
                VStack(spacing: PixelScale.px(3)) {
                    if pet.isAway {
                        awayStateView
                    } else {
                        activeStateView
                    }
                }
                .padding(PixelScale.px(2))
            }
        }
        .background(PixelTheme.background)
        .sheet(isPresented: $showTreatSheet) {
            TreatSelectionSheet(pet: pet, player: player)
        }
        .sheet(isPresented: $showAccessoryShop) {
            AccessoryShopView(player: player, pet: pet)
        }
        .alert("RECOVER \(pet.name.uppercased())?", isPresented: $showRecoveryConfirm) {
            Button("CANCEL", role: .cancel) { }
            Button("RECOVER") {
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

    // MARK: - Active State View

    private var activeStateView: some View {
        VStack(spacing: PixelScale.px(3)) {
            // Pet display
            petDisplaySection

            // XP Progress section
            xpProgressSection

            // Happiness section
            happinessSection

            // Actions section
            actionsSection

            // Species info
            speciesInfoSection

            // Tips
            tipsSection
        }
    }

    private var petDisplaySection: some View {
        PixelPanel(title: "YOUR PET") {
            VStack(spacing: PixelScale.px(2)) {
                // Pixel pet sprite with species colors
                PixelSpriteView(
                    sprite: PetSpriteLibrary.sprite(for: pet.species, stage: pet.evolutionStage),
                    pixelSize: 5,
                    palette: PixelTheme.PetPalette.palette(for: pet.species)
                )
                .frame(width: 80, height: 80)

                PixelText(pet.name.uppercased(), size: .large)

                HStack(spacing: PixelScale.px(2)) {
                    PixelText(pet.species.displayName.uppercased(), size: .small, color: PixelTheme.textSecondary)
                    PixelText("LV.\(pet.currentLevel)", size: .small)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var xpProgressSection: some View {
        PixelPanel(title: "XP PROGRESS") {
            VStack(spacing: PixelScale.px(2)) {
                HStack {
                    PixelText("TOTAL XP", size: .small, color: PixelTheme.textSecondary)
                    Spacer()
                    PixelText("\(pet.totalXP)", size: .medium)
                }

                PixelXPBar(
                    currentXP: pet.totalXP - pet.xpForCurrentLevel,
                    targetXP: pet.xpForNextLevel - pet.xpForCurrentLevel,
                    currentLevel: pet.currentLevel
                )

                Rectangle()
                    .fill(PixelTheme.border)
                    .frame(height: PixelScale.px(1))

                HStack {
                    PixelText("XP BONUS", size: .small, color: PixelTheme.textSecondary)
                    Spacer()
                    PixelText(xpBonusText.uppercased(), size: .small)
                }

                if PetManager.hasXPBonus(happiness: pet.happiness) {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .star, size: 12)
                        PixelText("+10% HAPPY BONUS!", size: .small)
                    }
                }
            }
        }
    }

    private var happinessSection: some View {
        PixelPanel(title: "HAPPINESS") {
            VStack(spacing: PixelScale.px(2)) {
                HStack {
                    PixelText(pet.mood.emoji, size: .medium, uppercase: false)
                    PixelText(pet.mood.rawValue.uppercased(), size: .small)
                    Spacer()
                    PixelText("\(Int(pet.happiness))%", size: .medium)
                }

                PixelHappinessBar(happiness: pet.happiness, mood: pet.mood)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Feed treats
            PixelPanel(title: "ACTIONS") {
                VStack(spacing: PixelScale.px(2)) {
                    Button {
                        showTreatSheet = true
                    } label: {
                        HStack(spacing: PixelScale.px(2)) {
                            PixelIconView(icon: .heartFill, size: 16)
                            PixelText("GIVE TREAT", size: .small)
                            Spacer()
                            PixelText(">", size: .small)
                        }
                        .padding(PixelScale.px(2))
                        .background(PixelTheme.gbLight)
                        .pixelOutline()
                    }

                    Button {
                        showAccessoryShop = true
                    } label: {
                        HStack(spacing: PixelScale.px(2)) {
                            PixelIconView(icon: .shop, size: 16)
                            PixelText("ACCESSORY SHOP", size: .small)
                            Spacer()
                            let ownedCount = player.unlockedAccessories.count
                            if ownedCount > 0 {
                                PixelText("\(ownedCount) OWNED", size: .small, color: PixelTheme.textSecondary)
                            }
                            PixelText(">", size: .small)
                        }
                        .padding(PixelScale.px(2))
                        .background(PixelTheme.gbLight)
                        .pixelOutline()
                    }
                }
            }
        }
    }

    private var speciesInfoSection: some View {
        PixelPanel(title: "SPECIES INFO") {
            VStack(spacing: PixelScale.px(2)) {
                HStack {
                    PixelText(pet.species.displayName.uppercased(), size: .medium)
                    Spacer()
                    PixelText(pet.species.personality.uppercased(), size: .small, color: PixelTheme.textSecondary)
                }

                PixelText(pet.species.description.uppercased(), size: .small, color: PixelTheme.textSecondary)

                Rectangle()
                    .fill(PixelTheme.border)
                    .frame(height: PixelScale.px(1))

                PixelText("SPECIAL BONUS", size: .small, color: PixelTheme.textSecondary)

                switch pet.species {
                case .dragon, .wolf:
                    PixelBonusRow(
                        icon: .dumbbell,
                        text: "STRENGTH XP",
                        bonus: "+\(bonusPercentage(for: .strength))%"
                    )
                case .cat:
                    PixelBonusRow(
                        icon: .run,
                        text: "CARDIO XP",
                        bonus: "+\(bonusPercentage(for: .cardio))%"
                    )
                case .plant, .dog:
                    VStack(spacing: PixelScale.px(1)) {
                        PixelBonusRow(
                            icon: .dumbbell,
                            text: "STRENGTH XP",
                            bonus: "+\(bonusPercentage(for: .strength))%"
                        )
                        PixelBonusRow(
                            icon: .run,
                            text: "CARDIO XP",
                            bonus: "+\(bonusPercentage(for: .cardio))%"
                        )
                    }
                }
            }
        }
    }

    private var tipsSection: some View {
        PixelPanel(title: "TIPS") {
            VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                PixelTipRow(text: "PET LEVELS UP FROM WORKOUT XP")
                PixelTipRow(text: "HAPPINESS DECAYS \(String(format: "%.1f", PetManager.passiveDecayPerDay))%/DAY")
                PixelTipRow(text: "WORKOUTS RESTORE +\(Int(PetManager.workoutHappinessBoost))% HAPPY")
                PixelTipRow(text: "TREATS BOOST HAPPINESS FAST")
                PixelTipRow(text: "KEEP HAPPY ≥90% FOR +10% XP")
            }
        }
    }

    // MARK: - Away State View

    private var awayStateView: some View {
        VStack(spacing: PixelScale.px(3)) {
            // Away message
            PixelPanel(title: "PET AWAY") {
                VStack(spacing: PixelScale.px(2)) {
                    PixelIconView(icon: .paw, size: 48)
                        .opacity(0.5)

                    PixelText("\(pet.name.uppercased()) RAN AWAY...", size: .medium)

                    PixelText("HAPPINESS HIT 0%", size: .small, color: PixelTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }

            // Recovery options
            PixelPanel(title: "RECOVERY OPTIONS") {
                VStack(spacing: PixelScale.px(2)) {
                    // Option 1: Complete workouts
                    let canRecoverWithWorkouts = PetManager.canRecoverWithWorkouts(pet: pet, player: player)

                    Button {
                        recoveryMethod = .workouts
                        showRecoveryConfirm = true
                    } label: {
                        HStack(spacing: PixelScale.px(2)) {
                            PixelIconView(icon: .dumbbell, size: 16)

                            VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                                PixelText("3 WORKOUTS", size: .small)
                                PixelText("IN LAST 7 DAYS", size: .small, color: PixelTheme.textSecondary)
                            }

                            Spacer()

                            if canRecoverWithWorkouts {
                                PixelIconView(icon: .check, size: 16)
                            }
                        }
                        .padding(PixelScale.px(2))
                        .background(canRecoverWithWorkouts ? PixelTheme.gbDark.opacity(0.3) : PixelTheme.gbLight)
                        .pixelOutline()
                    }
                    .disabled(!canRecoverWithWorkouts)
                    .opacity(canRecoverWithWorkouts ? 1 : 0.5)

                    // Option 2: Pay essence
                    let canRecoverWithEssence = PetManager.canRecoverWithEssence(pet: pet, player: player)

                    Button {
                        recoveryMethod = .essence
                        showRecoveryConfirm = true
                    } label: {
                        HStack(spacing: PixelScale.px(2)) {
                            PixelIconView(icon: .sparkle, size: 16)

                            VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                                PixelText("PAY 150 ESSENCE", size: .small)
                                PixelText("CURRENT: \(player.essenceCurrency)", size: .small, color: PixelTheme.textSecondary)
                            }

                            Spacer()

                            if canRecoverWithEssence {
                                PixelIconView(icon: .check, size: 16)
                            }
                        }
                        .padding(PixelScale.px(2))
                        .background(canRecoverWithEssence ? PixelTheme.gbDark.opacity(0.3) : PixelTheme.gbLight)
                        .pixelOutline()
                    }
                    .disabled(!canRecoverWithEssence)
                    .opacity(canRecoverWithEssence ? 1 : 0.5)
                }
            }

            // Info message
            PixelPanel(title: "INFO") {
                PixelText("AFTER RECOVERY \(pet.name.uppercased()) RETURNS WITH 50% HAPPINESS. YOU STILL EARN ESSENCE FROM WORKOUTS!", size: .small, color: PixelTheme.textSecondary)
            }
        }
    }

    // MARK: - Helpers

    private var xpBonusText: String {
        let strengthBonus = pet.species.xpMultiplier(for: .strength, petLevel: pet.currentLevel)
        let cardioBonus = pet.species.xpMultiplier(for: .cardio, petLevel: pet.currentLevel)

        switch pet.species {
        case .dragon, .wolf:
            let percentage = Int((strengthBonus - 1.0) * 100)
            return "+\(percentage)% Strength"
        case .cat:
            let percentage = Int((cardioBonus - 1.0) * 100)
            return "+\(percentage)% Cardio"
        case .plant, .dog:
            let percentage = Int((strengthBonus - 1.0) * 100)
            return "+\(percentage)% All XP"
        }
    }

    private func bonusPercentage(for workoutType: WorkoutType) -> String {
        let multiplier = pet.species.xpMultiplier(for: workoutType, petLevel: pet.currentLevel)
        let percentage = (multiplier - 1.0) * 100
        return String(format: "%.1f", percentage)
    }
}

// MARK: - Helper Views

struct PixelBonusRow: View {
    let icon: PixelIcon
    let text: String
    let bonus: String

    var body: some View {
        HStack(spacing: PixelScale.px(2)) {
            PixelIconView(icon: icon, size: 12)
            PixelText(text, size: .small, color: PixelTheme.textSecondary)
            Spacer()
            PixelText(bonus, size: .small)
        }
    }
}

struct PixelTipRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: PixelScale.px(1)) {
            PixelText("-", size: .small, color: PixelTheme.textSecondary)
            PixelText(text, size: .small, color: PixelTheme.textSecondary)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    PetDetailView(
        pet: {
            let pet = Pet(name: "Fluffy", species: .dragon)
            pet.happiness = 85
            pet.totalXP = 500
            return pet
        }(),
        player: {
            let p = Player(name: "Test")
            p.essenceCurrency = 250
            return p
        }()
    )
}
