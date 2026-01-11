import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var players: [Player]
    @State private var isInitialized = false

    private var player: Player? {
        players.first
    }

    var body: some View {
        Group {
            if let player = player {
                HomeView(player: player)
            } else {
                ProgressView()
                    .tint(Theme.primary)
            }
        }
        .background(Theme.background)
        .onAppear {
            initializeIfNeeded()
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
}

#Preview {
    ContentView()
        .modelContainer(for: [Player.self, Workout.self, WorkoutTemplate.self, CharacterAppearance.self], inMemory: true)
}
