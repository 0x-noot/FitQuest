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

    // Preferences
    var notificationsEnabled: Bool
    var soundEffectsEnabled: Bool

    // Rest days (streak protection)
    var restDaysUsedThisWeek: Int
    var lastRestDayReset: Date

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

    // Rank
    var currentRank: PlayerRank {
        PlayerRank.rank(for: currentLevel)
    }

    // Weekly stats
    var workoutsThisWeek: [Workout] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return workouts.filter { $0.completedAt >= startOfWeek }
    }

    var xpThisWeek: Int {
        workoutsThisWeek.reduce(0) { $0 + $1.xpEarned }
    }

    // Rest days
    var remainingRestDays: Int {
        resetRestDaysIfNeeded()
        return max(0, 2 - restDaysUsedThisWeek)
    }

    var hasWorkedOutToday: Bool {
        !todaysWorkouts.isEmpty
    }

    init(name: String = "Player") {
        self.id = UUID()
        self.name = name
        self.totalXP = 0
        self.currentStreak = 0
        self.highestStreak = 0
        self.createdAt = Date()
        self.notificationsEnabled = false
        self.soundEffectsEnabled = true
        self.restDaysUsedThisWeek = 0
        self.lastRestDayReset = Date()
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

    /// Use a rest day to protect streak (returns true if successful)
    @discardableResult
    func useRestDay() -> Bool {
        resetRestDaysIfNeeded()

        guard restDaysUsedThisWeek < 2 else { return false }
        guard currentStreak > 0 else { return false }
        guard !hasWorkedOutToday else { return false }

        // Check if we missed yesterday (would break streak)
        if let lastDate = lastWorkoutDate {
            let calendar = Calendar.current
            let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
            let lastWorkoutDay = calendar.startOfDay(for: lastDate)

            // Only allow rest day if last workout was yesterday or today
            if lastWorkoutDay < yesterday {
                return false
            }
        }

        restDaysUsedThisWeek += 1
        // Update lastWorkoutDate to today to maintain streak continuity
        lastWorkoutDate = Date()
        return true
    }

    /// Reset rest days counter at the start of each week
    private func resetRestDaysIfNeeded() {
        let calendar = Calendar.current
        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let lastResetWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastRestDayReset)) ?? Date()

        if currentWeekStart > lastResetWeekStart {
            restDaysUsedThisWeek = 0
            lastRestDayReset = Date()
        }
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
