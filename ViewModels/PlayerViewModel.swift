import SwiftUI
import SwiftData
import Observation

@Observable
class PlayerViewModel {
    private var modelContext: ModelContext
    private(set) var player: Player

    var showLevelUpCelebration = false
    var newLevel: Int = 0

    init(player: Player, modelContext: ModelContext) {
        self.player = player
        self.modelContext = modelContext
    }

    var currentLevel: Int {
        player.currentLevel
    }

    var totalXP: Int {
        player.totalXP
    }

    var xpProgress: Double {
        player.xpProgress
    }

    var xpToNextLevel: Int {
        player.xpToNextLevel
    }

    var currentStreak: Int {
        player.currentStreak
    }

    var highestStreak: Int {
        player.highestStreak
    }

    var streakMultiplier: Double {
        player.streakMultiplier
    }

    var isFirstWorkoutOfDay: Bool {
        player.isFirstWorkoutOfDay
    }

    var character: CharacterAppearance? {
        player.character
    }

    func addWorkout(_ workout: Workout) {
        // Update streak before adding XP
        player.updateStreak()

        // Add workout to player
        workout.player = player
        player.workouts.append(workout)
        modelContext.insert(workout)

        // Add XP and check for level up
        let previousLevel = player.currentLevel
        player.addXP(workout.xpEarned)

        if player.currentLevel > previousLevel {
            newLevel = player.currentLevel
            showLevelUpCelebration = true

            // Check for character unlocks at milestone levels
            checkForUnlocks()
        }

        try? modelContext.save()
    }

    private func checkForUnlocks() {
        // Milestone levels unlock character items
        guard let character = player.character else { return }

        let level = player.currentLevel
        let streak = player.highestStreak
        let workoutCount = player.workouts.count

        // Check all unlock requirements
        for (key, _) in CharacterUnlockRequirements.requirements {
            if CharacterUnlockRequirements.isUnlocked(key, level: level, streak: streak, workoutCount: workoutCount) {
                let parts = key.split(separator: ":")
                if parts.count == 2 {
                    character.unlock(String(parts[0]), index: Int(parts[1]) ?? 0)
                }
            }
        }
    }

    func dismissLevelUp() {
        showLevelUpCelebration = false
    }
}
