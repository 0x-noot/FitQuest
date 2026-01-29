import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @State private var isInitialized = false
    @State private var selectedTab: PixelTab = .home
    @State private var forceRefresh = false

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
                            case .history:
                                HistoryTab(player: player)
                            case .profile:
                                ProfileTab(player: player)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

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
        .id(forceRefresh)
        .onAppear {
            // Small delay to ensure SwiftData is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if players.isEmpty && !isInitialized {
                    initializePlayer()
                }
            }
        }
        .onChange(of: player?.hasWorkedOutToday) { _, hasWorkedOut in
            // Cancel today's notification if user has worked out
            if let worked = hasWorkedOut, worked {
                NotificationManager.shared.cancelTodayReminderIfWorkedOut(hasWorkedOutToday: true)
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
                // Force a refresh after saving
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    forceRefresh.toggle()
                }
            } catch {
                print("Error saving player: \(error)")
            }
        } else if let existingPlayer = players.first {
            // Existing users who have workouts should skip onboarding
            if !existingPlayer.hasCompletedOnboarding && !existingPlayer.workouts.isEmpty {
                existingPlayer.hasCompletedOnboarding = true
                // Set a reasonable default weekly goal for existing users
                if existingPlayer.weeklyWorkoutGoal == 0 {
                    existingPlayer.weeklyWorkoutGoal = 3
                }
                try? modelContext.save()
            }
        }

        // Seed workout templates
        seedTemplatesIfNeeded()
    }

    private func seedTemplatesIfNeeded() {
        let templateDescriptor = FetchDescriptor<WorkoutTemplate>()
        let existingTemplates = (try? modelContext.fetch(templateDescriptor)) ?? []
        let existingNames = Set(existingTemplates.map { $0.name })

        // Add any missing default templates
        for template in WorkoutTemplate.createDefaults() {
            if !existingNames.contains(template.name) {
                modelContext.insert(template)
            }
        }

        // Remove old templates that are no longer in defaults (except custom ones)
        let defaultNames = Set(WorkoutTemplate.createDefaults().map { $0.name })
        for template in existingTemplates {
            if !template.isCustom && !defaultNames.contains(template.name) {
                modelContext.delete(template)
            }
        }

        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self, Pet.self, DailyQuest.self], inMemory: true)
}
