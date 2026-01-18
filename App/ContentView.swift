import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @State private var isInitialized = false
    @State private var selectedTab: Tab = .home
    @State private var forceRefresh = false

    enum Tab {
        case home, history, profile
    }

    private var player: Player? {
        players.first
    }

    var body: some View {
        Group {
            if let player = player {
                TabView(selection: $selectedTab) {
                    HomeTab(player: player)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(Tab.home)

                    HistoryTab(player: player)
                        .tabItem {
                            Label("History", systemImage: "calendar")
                        }
                        .tag(Tab.history)

                    ProfileTab(player: player)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(Tab.profile)
                }
                .tint(Theme.primary)
            } else {
                // Loading state with visible indicator
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Theme.primary)
                    
                    Text("Loading...")
                        .foregroundColor(Theme.textSecondary)
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.background)
                .onAppear {
                    initializePlayer()
                }
            }
        }
        .background(Theme.background)
        .id(forceRefresh)
        .onAppear {
            configureTabBarAppearance()
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
            let newPlayer = Player(name: "Player")
            let character = CharacterAppearance()
            newPlayer.character = character
            modelContext.insert(newPlayer)
            modelContext.insert(character)
            
            do {
                try modelContext.save()
                // Force a refresh after saving
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    forceRefresh.toggle()
                }
            } catch {
                print("Error saving player: \(error)")
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

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.cardBackground)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self, CharacterAppearance.self], inMemory: true)
}
