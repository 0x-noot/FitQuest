import SwiftUI
import SwiftData

struct HomeTab: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player

    @State private var showQuickWorkout = false
    @State private var showCustomWorkout = false
    @State private var showLevelUp = false
    @State private var newLevel = 0
    @State private var showRankUp = false
    @State private var newRank: PlayerRank = .bronze
    @State private var currentQuote: String = QuoteManager.randomQuote()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Character Section
                    characterSection

                    // Stats Section
                    statsSection

                    // Streak Section
                    streakSection

                    // Action Buttons
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            .background(Theme.background)
            .navigationTitle("FitQuest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showQuickWorkout) {
                QuickWorkoutSheet(player: player, onComplete: handleWorkoutComplete)
            }
            .sheet(isPresented: $showCustomWorkout) {
                CustomWorkoutSheet(player: player, onComplete: handleWorkoutComplete)
            }
            .fullScreenCover(isPresented: $showLevelUp) {
                LevelUpView(level: newLevel) {
                    showLevelUp = false
                    // Check if rank also changed after level-up dismiss
                    if showRankUp {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showRankUp = true
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showRankUp) {
                RankUpView(rank: newRank) {
                    showRankUp = false
                }
            }
            .onAppear {
                currentQuote = QuoteManager.randomQuote()
            }
        }
    }

    private var characterSection: some View {
        VStack(spacing: 12) {
            // Motivational quote
            Text("\"\(currentQuote)\"")
                .font(.system(size: 14, weight: .medium).italic())
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            if let character = player.character {
                CharacterDisplayView(appearance: character, size: 160)

                Text(player.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(player.character?.background.gradient ?? CharacterBackground.defaultDark.gradient)
        )
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            // Level and Rank
            HStack {
                HStack(spacing: 8) {
                    LevelBadge(level: player.currentLevel, size: .large)
                    RankBadge(rank: player.currentRank, size: .medium)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(player.xpToNextLevel.formatted()) XP")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                    Text("to next level")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }
            }

            // XP Progress
            XPProgressBar(
                progress: player.xpProgress,
                currentXP: player.totalXP - LevelManager.xpRangeFor(level: player.currentLevel).start,
                targetXP: LevelManager.xpRangeFor(level: player.currentLevel).end - LevelManager.xpRangeFor(level: player.currentLevel).start
            )
        }
        .padding(20)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }

    private var streakSection: some View {
        VStack(spacing: 12) {
            StreakBadge(
                currentStreak: player.currentStreak,
                highestStreak: player.highestStreak
            )
            .frame(maxWidth: .infinity)

            // Rest day button (only show if user has a streak)
            if player.currentStreak > 0 {
                RestDayButton(player: player)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            PrimaryButton("Add Quick Workout", icon: "bolt.fill") {
                showQuickWorkout = true
            }

            SecondaryButton("Add Custom Workout", icon: "plus") {
                showCustomWorkout = true
            }
        }
        .padding(.top, 8)
    }

    private func handleWorkoutComplete(_ workout: Workout) {
        let previousLevel = player.currentLevel
        let previousRank = player.currentRank

        // Update streak
        player.updateStreak()

        // Add workout
        workout.player = player
        player.workouts.append(workout)
        modelContext.insert(workout)

        // Add XP
        player.addXP(workout.xpEarned)

        // Play sound effects if enabled
        if player.soundEffectsEnabled {
            SoundManager.shared.playXPGain()
            SoundManager.shared.playSuccessHaptic()
        }

        // Check for level up
        let didLevelUp = player.currentLevel > previousLevel
        if didLevelUp {
            newLevel = player.currentLevel
            if player.soundEffectsEnabled {
                SoundManager.shared.playLevelUp()
            }
            showLevelUp = true
        }

        // Check for rank up (after level up so we can sequence the celebrations)
        let didRankUp = player.currentRank != previousRank
        if didRankUp {
            newRank = player.currentRank
            if player.soundEffectsEnabled {
                SoundManager.shared.playRankUp()
            }
            // If also leveled up, rank-up will show after level-up dismisses
            if !didLevelUp {
                showRankUp = true
            }
        }

        try? modelContext.save()
    }
}

// MARK: - Level Up Celebration View

struct LevelUpView: View {
    let level: Int
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Theme.background.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Star burst effect
                ZStack {
                    ForEach(0..<8) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.warning.opacity(0.6))
                            .offset(y: -80)
                            .rotationEffect(.degrees(Double(index) * 45))
                    }

                    Circle()
                        .fill(Theme.primaryGradient)
                        .frame(width: 120, height: 120)

                    Text("\(level)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)

                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.warning)

                    Text("You reached Level \(level)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    if LevelManager.isMilestone(level: level) {
                        Text("Milestone reached! New items unlocked")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.secondary)
                            .padding(.top, 8)
                    }
                }

                Spacer()

                PrimaryButton("Continue") {
                    onDismiss()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    HomeTab(player: {
        let p = Player(name: "Test")
        p.totalXP = 2450
        p.currentStreak = 7
        p.highestStreak = 14
        p.character = CharacterAppearance()
        return p
    }())
    .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self, CharacterAppearance.self], inMemory: true)
}
