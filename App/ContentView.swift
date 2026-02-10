import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @State private var isInitialized = false
    @State private var selectedTab: PixelTab = .home
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    private var player: Player? {
        players.first
    }

    var body: some View {
        Group {
            if let player = player {
                if !player.hasCompletedOnboarding {
                    // Show onboarding for new users
                    OnboardingView(player: player)
                } else {
                    // Show main app with pixel tab bar
                    VStack(spacing: 0) {
                        // Content area
                        Group {
                            switch selectedTab {
                            case .home:
                                HomeTab(player: player)
                            case .clubs:
                                ClubsTab(player: player)
                            case .history:
                                HistoryTab(player: player)
                            case .profile:
                                ProfileTab(player: player)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        // Banner ad (hidden for premium users)
                        if !subscriptionManager.isPremium {
                            GeometryReader { geometry in
                                BannerAdView(
                                    adUnitID: AdManager.bannerAdUnitID,
                                    width: geometry.size.width
                                )
                            }
                            .frame(height: 50)
                        }

                        // Custom pixel tab bar
                        PixelTabBar(selectedTab: $selectedTab)
                    }
                    .background(PixelTheme.background)
                    .ignoresSafeArea(.keyboard)
                }
            } else {
                // Loading state with pixel art style
                VStack(spacing: PixelScale.px(4)) {
                    PixelText("LOADING...", size: .large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(PixelTheme.background)
                .onAppear {
                    initializePlayer()
                }
            }
        }
        .background(PixelTheme.background)
        .onAppear {
            // Small delay to ensure SwiftData is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if players.isEmpty && !isInitialized {
                    initializePlayer()
                }
            }
        }
        .task {
            seedTemplatesIfNeeded()
        }
        .onChange(of: player?.hasWorkedOutToday) { _, hasWorkedOut in
            // Cancel today's guilt notifications if user has worked out
            if let worked = hasWorkedOut, worked {
                NotificationManager.shared.cancelTodayGuiltNotifications()
            }
        }
    }

    private func initializePlayer() {
        guard !isInitialized else { return }
        isInitialized = true

        // Create player if none exists
        if players.isEmpty {
            let newPlayer = Player(name: "")
            // New players start with onboarding not completed
            newPlayer.hasCompletedOnboarding = false
            modelContext.insert(newPlayer)

            do {
                try modelContext.save()
            } catch {
                print("Error saving player: \(error)")
            }
        } else if let existingPlayer = players.first {
            // Existing users who have workouts should skip onboarding
            if !existingPlayer.hasCompletedOnboarding && !(existingPlayer.workouts ?? []).isEmpty {
                existingPlayer.hasCompletedOnboarding = true
                // Set a reasonable default weekly goal for existing users
                if existingPlayer.weeklyWorkoutGoal == 0 {
                    existingPlayer.weeklyWorkoutGoal = 3
                }
                try? modelContext.save()
            }
        }
    }

    private func seedTemplatesIfNeeded() {
        let existingTemplates = (try? modelContext.fetch(FetchDescriptor<WorkoutTemplate>())) ?? []
        let defaults = WorkoutTemplate.createDefaults()
        let defaultNames = Set(defaults.map { $0.name })

        // Track which default names already have a kept template
        var keptNames = Set<String>()

        for template in existingTemplates where !template.isCustom {
            if !defaultNames.contains(template.name) || keptNames.contains(template.name) {
                // Obsolete or duplicate — delete
                modelContext.delete(template)
            } else {
                // First occurrence of a current default — keep
                keptNames.insert(template.name)
            }
        }

        // Insert any missing defaults
        for template in defaults where !keptNames.contains(template.name) {
            modelContext.insert(template)
        }

        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self, Pet.self, DailyQuest.self, AuthState.self, Club.self, ClubActivity.self], inMemory: true)
}
