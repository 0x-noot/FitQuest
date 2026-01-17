import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @State private var isInitialized = false
    @State private var selectedTab: Tab = .home

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
                ProgressView()
                    .tint(Theme.primary)
            }
        }
        .background(Theme.background)
        .onAppear {
            initializeIfNeeded()
            configureTabBarAppearance()
        }
        .onChange(of: player?.hasWorkedOutToday) { _, hasWorkedOut in
            // Cancel today's notification if user has worked out
            if let worked = hasWorkedOut, worked {
                NotificationManager.shared.cancelTodayReminderIfWorkedOut(hasWorkedOutToday: true)
            }
        }
    }

    private func initializeIfNeeded() {
        guard !isInitialized else { return }
        isInitialized = true

        // Create player if none exists
        if players.isEmpty {
            let newPlayer = Player(name: "Player")
            let character = CharacterAppearance()
            newPlayer.character = character
            modelContext.insert(newPlayer)
        }

        // Seed workout templates - add any missing defaults
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
