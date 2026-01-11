import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player

    @State private var showQuickWorkout = false
    @State private var showCustomWorkout = false
    @State private var showHistory = false
    @State private var showCharacterCustomization = false
    @State private var showLevelUp = false
    @State private var newLevel = 0

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
                .padding(.bottom, 40)
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
            .sheet(isPresented: $showCharacterCustomization) {
                if let character = player.character {
                    CharacterCustomizationView(character: character)
                }
            }
            .fullScreenCover(isPresented: $showLevelUp) {
                LevelUpView(level: newLevel) {
                    showLevelUp = false
                }
            }
            .navigationDestination(isPresented: $showHistory) {
                WorkoutHistoryView(player: player)
            }
        }
    }

    private var characterSection: some View {
        VStack(spacing: 12) {
            if let character = player.character {
                CharacterDisplayView(appearance: character, size: 160)
                    .onTapGesture {
                        showCharacterCustomization = true
                    }

                Text("Tap to customize")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textMuted)
            }
        }
        .padding(.vertical, 10)
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            // Level
            HStack {
                LevelBadge(level: player.currentLevel, size: .large)
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
        StreakBadge(
            currentStreak: player.currentStreak,
            highestStreak: player.highestStreak
        )
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            PrimaryButton("Add Quick Workout", icon: "bolt.fill") {
                showQuickWorkout = true
            }

            SecondaryButton("Add Custom Workout", icon: "plus") {
                showCustomWorkout = true
            }

            TertiaryButton("View History", icon: "clock") {
                showHistory = true
            }
        }
        .padding(.top, 8)
    }

    private func handleWorkoutComplete(_ workout: Workout) {
        let previousLevel = player.currentLevel

        // Update streak
        player.updateStreak()

        // Add workout
        workout.player = player
        player.workouts.append(workout)
        modelContext.insert(workout)

        // Add XP
        player.addXP(workout.xpEarned)

        // Check for level up
        if player.currentLevel > previousLevel {
            newLevel = player.currentLevel
            showLevelUp = true
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
    HomeView(player: {
        let p = Player(name: "Test")
        p.totalXP = 2450
        p.currentStreak = 7
        p.highestStreak = 14
        p.character = CharacterAppearance()
        return p
    }())
    .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self, CharacterAppearance.self], inMemory: true)
}
