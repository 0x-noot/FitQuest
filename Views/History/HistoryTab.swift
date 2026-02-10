import SwiftUI
import SwiftData

// MARK: - History Tab (Pixel Art Style)

struct HistoryTab: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player
    @Query(filter: #Predicate<WorkoutTemplate> { !$0.isCustom }) private var templates: [WorkoutTemplate]

    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showPaywall = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    private var recentWorkouts: [Workout] {
        (player.workouts ?? []).sorted { $0.completedAt > $1.completedAt }
    }

    private var totalXPEarned: Int {
        (player.workouts ?? []).reduce(0) { $0 + $1.xpEarned }
    }

    private var totalWorkouts: Int {
        (player.workouts ?? []).count
    }

    private var xpThisWeek: Int {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return (player.workouts ?? [])
            .filter { $0.completedAt >= weekStart }
            .reduce(0) { $0 + $1.xpEarned }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: PixelScale.px(2)) {
                // Title bar
                HStack {
                    PixelText("HISTORY", size: .large)
                    Spacer()
                }
                .padding(.horizontal, PixelScale.px(2))
                .padding(.top, PixelScale.px(2))

                // Weekly workout plan
                if player.hasCompletedOnboarding {
                    if subscriptionManager.isPremium {
                        WeeklyPlanView(
                            player: player,
                            templates: templates,
                            onExerciseTap: { _, template in
                                if let template {
                                    selectedTemplate = template
                                }
                            }
                        )
                        .padding(.horizontal, PixelScale.px(2))
                    } else {
                        lockedPlanView
                            .padding(.horizontal, PixelScale.px(2))
                    }
                }

                // This week panel
                thisWeekPanel
                    .padding(.horizontal, PixelScale.px(2))

                // Stats row
                HStack(spacing: PixelScale.px(2)) {
                    PixelStatBox(value: "\(totalWorkouts)", label: "TOTAL")
                    PixelStatBox(value: formatXP(totalXPEarned), label: "XP")
                }
                .padding(.horizontal, PixelScale.px(2))

                // Recent workouts
                PixelPanel(title: "RECENT") {
                    if recentWorkouts.isEmpty {
                        VStack(spacing: PixelScale.px(2)) {
                            PixelIconView(icon: .scroll, size: 24)
                            PixelText("NO WORKOUTS YET", size: .small, color: PixelTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PixelScale.px(4))
                    } else {
                        VStack(spacing: PixelScale.px(1)) {
                            ForEach(recentWorkouts.prefix(5)) { workout in
                                PixelWorkoutRow(workout: workout)
                            }
                        }
                    }
                }
                .padding(.horizontal, PixelScale.px(2))
                .padding(.bottom, PixelScale.px(2))
            }
        }
        .background(PixelTheme.background)
        .sheet(item: $selectedTemplate) { template in
            WorkoutInputSheet(
                template: template,
                player: player,
                onComplete: { workout in
                    handleWorkoutComplete(workout)
                    selectedTemplate = nil
                }
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(highlightedFeature: .workoutPlans)
        }
    }

    // MARK: - Locked Plan View

    private var lockedPlanView: some View {
        PixelPanel(title: "MY PLAN") {
            VStack(spacing: PixelScale.px(2)) {
                PixelIconView(icon: .star, size: 32, color: PixelTheme.textSecondary)
                PremiumBadge()
                PixelText("UNLOCK WORKOUT PLANS", size: .medium)
                PixelText("GET PERSONALIZED WEEKLY", size: .small, color: PixelTheme.textSecondary)
                PixelText("WORKOUT PLANS WITH PREMIUM", size: .small, color: PixelTheme.textSecondary)
                PixelButton("UPGRADE", icon: .star, style: .primary) {
                    showPaywall = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PixelScale.px(2))
        }
    }

    // MARK: - This Week Panel

    private var thisWeekPanel: some View {
        PixelPanel(title: "THIS WEEK") {
            VStack(spacing: PixelScale.px(2)) {
                // Weekly progress bar
                PixelWeeklyBar(
                    daysCompleted: player.daysWorkedOutThisWeek,
                    goal: player.weeklyWorkoutGoal
                )

                // XP and streak
                HStack {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .bolt, size: 12)
                        PixelText("\(xpThisWeek) XP", size: .small)
                    }

                    Spacer()

                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .flame, size: 12)
                        PixelText("\(player.currentStreak) STREAK", size: .small)
                    }
                }

                // Rest day / streak freeze
                if player.currentStreak > 0 {
                    Rectangle()
                        .fill(PixelTheme.border.opacity(0.3))
                        .frame(height: PixelScale.px(1))

                    RestDayButton(player: player)
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatXP(_ xp: Int) -> String {
        if xp >= 1000 {
            return String(format: "%.1fK", Double(xp) / 1000.0)
        }
        return "\(xp)"
    }

    // MARK: - Workout Complete Handler

    private func handleWorkoutComplete(_ workout: Workout) {
        let isFirstWorkoutOfDay = player.isFirstWorkoutOfDay

        player.updateStreak()
        player.updateWeeklyStreak(isFirstWorkout: isFirstWorkoutOfDay)

        workout.player = player
        player.workouts?.append(workout)
        modelContext.insert(workout)

        // Update pet XP
        if let pet = player.pet {
            pet.totalXP += workout.xpEarned
            PetManager.onWorkoutComplete(pet: pet)
        }

        // Award essence
        let essenceEarned = PetManager.essenceEarnedForWorkout(xp: workout.xpEarned)
        player.essenceCurrency += essenceEarned

        // Mark plan day as completed
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: Date())
        let dayLabels = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let todayLabel = dayLabels[dayOfWeek - 1]
        player.markPlanDayCompleted(todayLabel)

        // Check quest progress
        for quest in (player.dailyQuests ?? []) {
            _ = QuestManager.shared.checkQuestCompletion(
                quest: quest,
                player: player,
                workout: workout
            )
        }

        if player.notificationsEnabled {
            NotificationManager.shared.cancelTodayGuiltNotifications()
            NotificationManager.shared.cancelTodayPetNotifications()
        }

        if player.soundEffectsEnabled {
            SoundManager.shared.playXPGain()
            SoundManager.shared.playSuccessHaptic()
        }

        try? modelContext.save()

        // Sync profile to CloudKit
        if let appleUserID = player.appleUserID {
            Task {
                try? await CloudKitService.shared.createOrUpdateUserProfile(
                    player: player,
                    appleUserID: appleUserID
                )
            }
        }

        // Post activity to clubs
        postClubActivity(workout: workout)
    }

    private func postClubActivity(workout: Workout) {
        guard let userID = player.appleUserID else { return }
        guard !(player.clubs ?? []).isEmpty else { return }

        let displayName = player.effectiveDisplayName

        Task {
            for club in (player.clubs ?? []) {
                try? await CloudKitService.shared.postActivity(
                    clubRecordName: club.cloudKitRecordName,
                    userID: userID,
                    displayName: displayName,
                    type: .workout,
                    xp: workout.xpEarned
                )

                try? await CloudKitService.shared.updateLeaderboardEntry(
                    clubRecordName: club.cloudKitRecordName,
                    userID: userID,
                    displayName: displayName,
                    weeklyXP: player.xpThisWeek,
                    weeklyWorkouts: player.workoutsThisWeek.count,
                    streak: player.currentStreak
                )
            }
        }
    }
}

// MARK: - Pixel Workout Row

struct PixelWorkoutRow: View {
    let workout: Workout

    private var dateText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(workout.completedAt) {
            return "TODAY"
        } else if calendar.isDateInYesterday(workout.completedAt) {
            return "YESTERDAY"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: workout.completedAt).uppercased()
        }
    }

    var body: some View {
        HStack(spacing: PixelScale.px(2)) {
            // Icon
            PixelIconView(
                icon: workout.workoutType == .cardio ? .run : .dumbbell,
                size: 12
            )

            // Name (truncated)
            PixelText(
                String(workout.name.prefix(10)).uppercased(),
                size: .small
            )

            Spacer()

            // Date
            PixelText(dateText, size: .small, color: PixelTheme.textSecondary)

            // XP
            PixelText("+\(workout.xpEarned)", size: .small)
        }
        .padding(.vertical, PixelScale.px(1))
    }
}

// MARK: - Pixel Weekly Summary Card

struct PixelWeeklySummaryCard: View {
    let daysWorkedOutThisWeek: Int
    let weeklyGoal: Int
    let xpThisWeek: Int
    let currentStreak: Int

    var body: some View {
        PixelPanel(title: "WEEKLY GOAL") {
            VStack(spacing: PixelScale.px(2)) {
                PixelWeeklyBar(daysCompleted: daysWorkedOutThisWeek, goal: weeklyGoal)

                HStack {
                    PixelText("XP: \(xpThisWeek)", size: .small)
                    Spacer()
                    PixelText("STREAK: \(currentStreak)", size: .small)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryTab(player: {
        let p = Player(name: "Test")
        p.daysWorkedOutThisWeek = 3
        p.weeklyWorkoutGoal = 5
        p.currentStreak = 7
        p.hasCompletedOnboarding = true
        p.workoutStyleRaw = "balanced"
        p.fitnessLevelRaw = "intermediate"
        p.fitnessGoalsRaw = "buildMuscle"
        p.equipmentAccessRaw = "full_gym"
        p.workouts = [
            Workout(name: "Running", workoutType: .cardio, xpEarned: 156, durationMinutes: 30),
            Workout(name: "Bench Press", workoutType: .strength, xpEarned: 142, weight: 135, reps: 10, sets: 3)
        ]
        return p
    }())
    .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self, Pet.self, DailyQuest.self, AuthState.self, Club.self, ClubActivity.self], inMemory: true)
}
