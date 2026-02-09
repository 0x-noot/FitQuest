import SwiftUI
import SwiftData

// MARK: - Profile Tab (Pixel Art Style)

struct ProfileTab: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player

    @State private var isEditingName = false
    @State private var editedName: String = ""
    @State private var showPermissionDeniedAlert = false
    @State private var showSignOutConfirm = false

    @StateObject private var authManager = AuthManager.shared

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

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

            // Account section
            accountSection
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
                    // Small pet sprite with species colors
                    PixelSpriteView(
                        sprite: PetSpriteLibrary.sprite(for: pet.species, stage: pet.evolutionStage),
                        pixelSize: 1.5,
                        palette: PixelTheme.PetPalette.palette(for: pet.species)
                    )
                    .frame(width: 48, height: 48, alignment: .center)

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
                PixelStatRow(icon: .dumbbell, label: "WORKOUTS", value: "\((player.workouts ?? []).count)")

                if let pet = player.pet {
                    PixelStatRow(icon: .bolt, label: "PET XP", value: "\(pet.totalXP)")
                }
            }
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        PixelPanel(title: "ACCOUNT") {
            VStack(spacing: PixelScale.px(1)) {
                if player.isAuthenticated {
                    // Signed in state
                    HStack(spacing: PixelScale.px(2)) {
                        PixelIconView(icon: .check, size: 12, color: Color(hex: "4ECDC4"))
                        PixelText("SIGNED IN", size: .small, color: Color(hex: "4ECDC4"))
                        Spacer()
                        PixelIconView(icon: .person, size: 12)
                    }

                    Button {
                        editedName = player.displayName ?? ""
                        isEditingName = true
                    } label: {
                        HStack {
                            PixelText("NAME", size: .small, color: PixelTheme.textSecondary)
                            Spacer()
                            PixelText(player.effectiveDisplayName.uppercased(), size: .small)
                            PixelIconView(icon: .arrow, size: 10, color: PixelTheme.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)

                    HStack {
                        PixelText("CLUBS", size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                        PixelText("\(player.clubCount)/\(ClubManager.maxClubsPerUser)", size: .small)
                    }

                    // Sign out button
                    Button(action: { showSignOutConfirm = true }) {
                        HStack {
                            PixelText("SIGN OUT", size: .small, color: Color(hex: "FF5555"))
                            Spacer()
                            PixelIconView(icon: .arrow, size: 12, color: Color(hex: "FF5555"))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, PixelScale.px(1))
                } else {
                    // Not signed in state
                    HStack(spacing: PixelScale.px(2)) {
                        PixelIconView(icon: .person, size: 12, color: PixelTheme.textSecondary)
                        PixelText("NOT SIGNED IN", size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                    }

                    PixelText("SIGN IN TO SYNC DATA", size: .small, color: PixelTheme.textSecondary)
                    PixelText("AND JOIN CLUBS", size: .small, color: PixelTheme.textSecondary)
                }
            }
        }
        .alert("Sign Out?", isPresented: $showSignOutConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Your local data will be kept, but you won't be able to sync or use clubs until you sign in again.")
        }
        .alert("Edit Name", isPresented: $isEditingName) {
            TextField("Display Name", text: $editedName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    player.displayName = trimmed
                    try? modelContext.save()
                }
            }
        } message: {
            Text("Enter your display name")
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
                    PixelText(appVersion, size: .small, color: PixelTheme.textSecondary)
                }
                .padding(.top, PixelScale.px(1))
            }
        }
        .alert("Notifications Disabled", isPresented: $showPermissionDeniedAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings to receive workout reminders and pet updates.")
        }
    }

    // MARK: - Notification Handler

    private func handleNotificationToggle(_ enabled: Bool) async {
        if enabled {
            // Check current authorization status first
            let settings = await UNUserNotificationCenter.current().notificationSettings()

            if settings.authorizationStatus == .denied {
                // Permission was previously denied - show alert to open Settings
                await MainActor.run {
                    showPermissionDeniedAlert = true
                }
                return
            }

            let granted = await NotificationManager.shared.requestAuthorization()
            if granted {
                player.notificationsEnabled = true

                // Schedule guilt notifications if user has pet and hasn't worked out today
                if let pet = player.pet, !player.hasWorkedOutToday {
                    NotificationManager.shared.scheduleGuiltReminders(pet: pet)
                }

                // Schedule pet happiness notifications
                if let pet = player.pet {
                    NotificationManager.shared.schedulePetNotifications(for: pet)
                }

                try? modelContext.save()
            } else {
                // User denied the permission request
                await MainActor.run {
                    showPermissionDeniedAlert = true
                }
            }
        } else {
            player.notificationsEnabled = false
            NotificationManager.shared.cancelGuiltReminders()
            NotificationManager.shared.cancelPetNotifications()
            try? modelContext.save()
        }
    }

    // MARK: - Sign Out Handler

    private func signOut() {
        authManager.signOut()

        if let authState = player.authState {
            authState.signOut()
        }

        player.appleUserID = nil
        player.cloudKitRecordName = nil

        try? modelContext.save()
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
            (.dumbbell, "10 WORKOUTS", (player.workouts ?? []).count >= 10),
            (.dumbbell, "50 WORKOUTS", (player.workouts ?? []).count >= 50),
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
