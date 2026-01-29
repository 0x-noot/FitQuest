import SwiftUI
import SwiftData

// MARK: - Profile Tab (Pixel Art Style)

struct ProfileTab: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player

    @State private var isEditingName = false
    @State private var editedName: String = ""

    var body: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Title bar
            HStack {
                PixelText("PROFILE", size: .large)
                Spacer()
            }
            .padding(.horizontal, PixelScale.px(2))
            .padding(.top, PixelScale.px(2))

            // Pet section
            petSection
                .padding(.horizontal, PixelScale.px(2))

            // Stats section
            statsSection
                .padding(.horizontal, PixelScale.px(2))

            // Settings section
            settingsSection
                .padding(.horizontal, PixelScale.px(2))

            Spacer()
        }
        .background(PixelTheme.background)
    }

    // MARK: - Pet Section

    private var petSection: some View {
        PixelPanel(title: "PET") {
            if let pet = player.pet {
                HStack(spacing: PixelScale.px(3)) {
                    // Small pet sprite
                    PixelSpriteView(
                        sprite: PetSpriteLibrary.sprite(for: pet.species, stage: pet.evolutionStage),
                        pixelSize: 3
                    )
                    .frame(width: 48, height: 48)

                    // Pet info
                    VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                        PixelText(pet.name, size: .medium)
                        PixelText("LV.\(pet.currentLevel) \(pet.species.displayName.uppercased())", size: .small, color: PixelTheme.textSecondary)

                        // Happiness bar
                        HStack(spacing: PixelScale.px(1)) {
                            PixelText(pet.mood.emoji, size: .small, uppercase: false)
                            PixelProgressBar(progress: pet.happiness / 100.0, segments: 6, height: PixelScale.px(2))
                        }
                    }
                }
            } else {
                HStack {
                    PixelIconView(icon: .paw, size: 24)
                    PixelText("NO PET", size: .medium, color: PixelTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        PixelPanel(title: "STATS") {
            VStack(spacing: PixelScale.px(1)) {
                PixelStatRow(icon: .flame, label: "STREAK", value: "\(player.currentStreak)")
                PixelStatRow(icon: .trophy, label: "BEST", value: "\(player.highestStreak)")
                PixelStatRow(icon: .sparkle, label: "ESSENCE", value: "\(player.essenceCurrency)")
                PixelStatRow(icon: .dumbbell, label: "WORKOUTS", value: "\(player.workouts.count)")

                if let pet = player.pet {
                    PixelStatRow(icon: .bolt, label: "PET XP", value: "\(pet.totalXP)")
                }
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        PixelPanel(title: "SETTINGS") {
            VStack(spacing: PixelScale.px(1)) {
                // Sound toggle
                PixelToggle(label: "SOUND", isOn: $player.soundEffectsEnabled)

                // Notifications toggle
                PixelToggle(
                    label: "NOTIFY",
                    isOn: Binding(
                        get: { player.notificationsEnabled },
                        set: { newValue in
                            Task {
                                await handleNotificationToggle(newValue)
                            }
                        }
                    )
                )

                // Version info
                HStack {
                    PixelText("VERSION", size: .small, color: PixelTheme.textSecondary)
                    Spacer()
                    PixelText("2.0.0", size: .small, color: PixelTheme.textSecondary)
                }
                .padding(.top, PixelScale.px(1))
            }
        }
    }

    // MARK: - Notification Handler

    private func handleNotificationToggle(_ enabled: Bool) async {
        if enabled {
            let granted = await NotificationManager.shared.requestAuthorization()
            if granted {
                player.notificationsEnabled = true
                NotificationManager.shared.scheduleDailyReminder()
                try? modelContext.save()
            }
        } else {
            player.notificationsEnabled = false
            NotificationManager.shared.cancelDailyReminder()
            try? modelContext.save()
        }
    }
}

// MARK: - Pixel Stat Row

struct PixelStatRow: View {
    let icon: PixelIcon
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: PixelScale.px(2)) {
            PixelIconView(icon: icon, size: 12)
            PixelText(label, size: .small)
            Spacer()
            PixelText(value, size: .small)
        }
        .padding(.vertical, PixelScale.px(1))
    }
}

// MARK: - Pixel Achievements Section

struct PixelAchievementsSection: View {
    let player: Player

    private var achievements: [(icon: PixelIcon, title: String, unlocked: Bool)] {
        [
            (.flame, "7 DAY STREAK", player.highestStreak >= 7),
            (.flame, "30 DAY STREAK", player.highestStreak >= 30),
            (.dumbbell, "10 WORKOUTS", player.workouts.count >= 10),
            (.dumbbell, "50 WORKOUTS", player.workouts.count >= 50),
            (.star, "REACH LV.10", (player.pet?.currentLevel ?? 0) >= 10),
            (.dragon, "EVOLVE PET", (player.pet?.evolutionStage ?? .baby) != .baby),
        ]
    }

    var body: some View {
        PixelPanel(title: "ACHIEVEMENTS") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PixelScale.px(2)) {
                ForEach(achievements.indices, id: \.self) { index in
                    let achievement = achievements[index]
                    VStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: achievement.icon, size: 16)
                            .opacity(achievement.unlocked ? 1.0 : 0.3)
                        PixelText(achievement.title, size: .small, color: achievement.unlocked ? PixelTheme.text : PixelTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(PixelScale.px(2))
                    .background(achievement.unlocked ? PixelTheme.gbDark.opacity(0.3) : Color.clear)
                    .pixelOutline()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileTab(player: {
        let p = Player(name: "FitGamer")
        p.currentStreak = 7
        p.highestStreak = 14
        p.essenceCurrency = 250
        let pet = Pet(name: "Ember", species: .dragon)
        pet.totalXP = 2450
        p.pet = pet
        return p
    }())
    .modelContainer(for: [Player.self, Workout.self, Pet.self], inMemory: true)
}
