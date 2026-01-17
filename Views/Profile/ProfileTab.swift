import SwiftUI
import SwiftData

struct ProfileTab: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player

    @State private var showCharacterCustomization = false
    @State private var isEditingName = false
    @State private var editedName: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar section
                    avatarSection

                    // Name section
                    nameSection

                    // Stats overview
                    statsSection

                    // Achievements
                    AchievementsSection(player: player)

                    // Preferences
                    preferencesSection

                    // About
                    aboutSection
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Theme.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showCharacterCustomization) {
                if let character = player.character {
                    CharacterCustomizationView(character: character, playerRank: player.currentRank)
                }
            }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 16) {
            if let character = player.character {
                CharacterDisplayView(appearance: character, size: 140)
            }

            Button {
                showCharacterCustomization = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                    Text("Customize Avatar")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(Theme.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Theme.primary.opacity(0.15))
                .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DISPLAY NAME")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .tracking(1)

            HStack {
                if isEditingName {
                    TextField("Enter name", text: $editedName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.textPrimary)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            saveName()
                        }

                    Button {
                        saveName()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.success)
                    }

                    Button {
                        isEditingName = false
                        editedName = player.name
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.textMuted)
                    }
                } else {
                    Text(player.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.textPrimary)

                    Spacer()

                    Button {
                        editedName = player.name
                        isEditingName = true
                    } label: {
                        Image(systemName: "pencil.circle")
                            .font(.system(size: 22))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(12)
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATISTICS")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .tracking(1)

            VStack(spacing: 0) {
                StatRow(label: "Current Level", value: "\(player.currentLevel)", icon: "star.fill", color: Theme.warning)
                Divider().background(Theme.elevated)
                StatRow(label: "Total XP", value: player.totalXP.formatted(), icon: "bolt.fill", color: Theme.success)
                Divider().background(Theme.elevated)
                StatRow(label: "Total Workouts", value: "\(player.workouts.count)", icon: "figure.run", color: Theme.primary)
                Divider().background(Theme.elevated)
                StatRow(label: "Current Streak", value: "\(player.currentStreak) days", icon: "flame.fill", color: Theme.streak)
                Divider().background(Theme.elevated)
                StatRow(label: "Highest Streak", value: "\(player.highestStreak) days", icon: "trophy.fill", color: Theme.warning)
                Divider().background(Theme.elevated)
                StatRow(label: "Member Since", value: formattedDate(player.createdAt), icon: "calendar", color: Theme.secondary)
            }
            .background(Theme.cardBackground)
            .cornerRadius(12)
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PREFERENCES")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .tracking(1)

            VStack(spacing: 0) {
                PreferenceRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Daily reminder at 1 PM",
                    color: Theme.warning
                ) {
                    Toggle("", isOn: Binding(
                        get: { player.notificationsEnabled },
                        set: { newValue in
                            Task {
                                await handleNotificationToggle(newValue)
                            }
                        }
                    ))
                    .tint(Theme.primary)
                    .labelsHidden()
                }

                Divider().background(Theme.elevated)

                PreferenceRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound Effects",
                    subtitle: "Play sounds on actions",
                    color: Theme.secondary
                ) {
                    Toggle("", isOn: $player.soundEffectsEnabled)
                        .tint(Theme.primary)
                        .labelsHidden()
                }

                Divider().background(Theme.elevated)

                PreferenceRow(
                    icon: "scalemass.fill",
                    title: "Weight Unit",
                    subtitle: "Pounds (lbs)",
                    color: Theme.primary
                ) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)
                }
            }
            .background(Theme.cardBackground)
            .cornerRadius(12)
        }
    }

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

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .tracking(1)

            VStack(spacing: 0) {
                AboutRow(title: "Version", value: "1.2.0")
                Divider().background(Theme.elevated)
                AboutRow(title: "Build", value: "27 workouts, 11 achievements")
            }
            .background(Theme.cardBackground)
            .cornerRadius(12)
        }
    }

    private func saveName() {
        let trimmed = editedName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            player.name = trimmed
            try? modelContext.save()
        }
        isEditingName = false
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 15))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Preference Row

struct PreferenceRow<Trailing: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textPrimary)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted)
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - About Row

struct AboutRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 15))
                .foregroundColor(Theme.textMuted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    ProfileTab(player: {
        let p = Player(name: "FitGamer")
        p.totalXP = 2450
        p.currentStreak = 7
        p.highestStreak = 14
        p.character = CharacterAppearance()
        return p
    }())
    .modelContainer(for: [Player.self, Workout.self, CharacterAppearance.self], inMemory: true)
}
