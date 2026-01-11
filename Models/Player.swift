import SwiftData
import Foundation

@Model
final class Player {
    var id: UUID
    var name: String
    var totalXP: Int
    var currentStreak: Int
    var highestStreak: Int
    var lastWorkoutDate: Date?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Workout.player)
    var workouts: [Workout] = []

    @Relationship(deleteRule: .cascade, inverse: \CharacterAppearance.player)
    var character: CharacterAppearance?

    // Computed properties
    var currentLevel: Int {
        LevelManager.levelFor(xp: totalXP)
    }

    var xpForCurrentLevel: Int {
        LevelManager.xpRangeFor(level: currentLevel).start
    }

    var xpForNextLevel: Int {
        LevelManager.xpRangeFor(level: currentLevel).end
    }

    var xpProgress: Double {
        LevelManager.progressFor(xp: totalXP)
    }

    var xpToNextLevel: Int {
        LevelManager.xpToNextLevel(currentXP: totalXP)
    }

    var isFirstWorkoutOfDay: Bool {
        StreakManager.isFirstWorkoutOfDay(lastWorkoutDate: lastWorkoutDate)
    }

    var streakMultiplier: Double {
        XPCalculator.streakMultiplier(streak: currentStreak)
    }

    init(name: String = "Player") {
        self.id = UUID()
        self.name = name
        self.totalXP = 0
        self.currentStreak = 0
        self.highestStreak = 0
        self.createdAt = Date()
    }

    /// Add XP and return if leveled up
    @discardableResult
    func addXP(_ amount: Int) -> Bool {
        let previousLevel = currentLevel
        totalXP += amount
        return currentLevel > previousLevel
    }

    /// Update streak after completing a workout
    func updateStreak() {
        let newStreak = StreakManager.calculateStreak(
            currentStreak: currentStreak,
            lastWorkoutDate: lastWorkoutDate
        )
        currentStreak = newStreak
        if newStreak > highestStreak {
            highestStreak = newStreak
        }
        lastWorkoutDate = Date()
    }

    /// Get today's workouts
    var todaysWorkouts: [Workout] {
        workouts.filter { StreakManager.isSameDay($0.completedAt, Date()) }
    }

    /// Get total XP earned today
    var todaysXP: Int {
        todaysWorkouts.reduce(0) { $0 + $1.xpEarned }
    }
}
