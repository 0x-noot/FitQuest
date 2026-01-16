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

        // Seed workout templates if none exist
        let templateDescriptor = FetchDescriptor<WorkoutTemplate>()
        let existingTemplates = (try? modelContext.fetch(templateDescriptor)) ?? []

        if existingTemplates.isEmpty {
            for template in WorkoutTemplate.createDefaults() {
                modelContext.insert(template)
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
