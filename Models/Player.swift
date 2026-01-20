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

    // Onboarding
    var hasCompletedOnboarding: Bool
    var fitnessGoalsRaw: String
    var fitnessLevelRaw: String
    var workoutStyleRaw: String
    var equipmentAccessRaw: String
    var focusAreasRaw: String

    // Weekly streak system
    var weeklyWorkoutGoal: Int
    var currentWeeklyStreak: Int
    var highestWeeklyStreak: Int
    var lastWeekCompleted: Date?
    var daysWorkedOutThisWeek: Int
    var lastWeeklyStreakReset: Date

    @Relationship(deleteRule: .cascade, inverse: \Workout.player)
    var workouts: [Workout] = []

    @Relationship(deleteRule: .cascade, inverse: \CharacterAppearance.player)
    var character: CharacterAppearance?

    // Pet system
    var essenceCurrency: Int
    @Relationship(deleteRule: .cascade, inverse: \Pet.player)
    var pet: Pet?

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

    // Onboarding computed properties
    var fitnessGoals: [FitnessGoal] {
        get {
            guard !fitnessGoalsRaw.isEmpty else { return [] }
            return fitnessGoalsRaw.split(separator: ",").compactMap { FitnessGoal(rawValue: String($0)) }
        }
        set {
            fitnessGoalsRaw = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }

    var fitnessLevel: FitnessLevel? {
        get { FitnessLevel(rawValue: fitnessLevelRaw) }
        set { fitnessLevelRaw = newValue?.rawValue ?? "" }
    }

    var workoutStyle: WorkoutStyle? {
        get { WorkoutStyle(rawValue: workoutStyleRaw) }
        set { workoutStyleRaw = newValue?.rawValue ?? "" }
    }

    var equipmentAccess: [EquipmentAccess] {
        get {
            guard !equipmentAccessRaw.isEmpty else { return [] }
            return equipmentAccessRaw.split(separator: ",").compactMap { EquipmentAccess(rawValue: String($0)) }
        }
        set {
            equipmentAccessRaw = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }

    var focusAreas: [FocusArea] {
        get {
            guard !focusAreasRaw.isEmpty else { return [] }
            return focusAreasRaw.split(separator: ",").compactMap { FocusArea(rawValue: String($0)) }
        }
        set {
            focusAreasRaw = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }

    var hasBuildMuscleGoal: Bool {
        fitnessGoals.contains(.buildMuscle)
    }

    // Weekly streak progress
    var weeklyGoalProgress: Double {
        guard weeklyWorkoutGoal > 0 else { return 0 }
        return min(1.0, Double(daysWorkedOutThisWeek) / Double(weeklyWorkoutGoal))
    }

    var hasMetWeeklyGoal: Bool {
        daysWorkedOutThisWeek >= weeklyWorkoutGoal
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

        // Onboarding defaults
        self.hasCompletedOnboarding = false
        self.fitnessGoalsRaw = ""
        self.fitnessLevelRaw = ""
        self.workoutStyleRaw = ""
        self.equipmentAccessRaw = ""
        self.focusAreasRaw = ""

        // Weekly streak defaults
        self.weeklyWorkoutGoal = 3
        self.currentWeeklyStreak = 0
        self.highestWeeklyStreak = 0
        self.lastWeekCompleted = nil
        self.daysWorkedOutThisWeek = 0
        self.lastWeeklyStreakReset = Date()

        // Pet system defaults
        self.essenceCurrency = 0
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

    /// Reset weekly workout counter at the start of each week
    func resetWeeklyWorkoutsIfNeeded() {
        let calendar = Calendar.current
        let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let lastResetWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastWeeklyStreakReset)) ?? Date()

        if currentWeekStart > lastResetWeekStart {
            daysWorkedOutThisWeek = 0
            lastWeeklyStreakReset = Date()
        }
    }

    /// Update weekly streak after completing a workout
    func updateWeeklyStreak(isFirstWorkout: Bool? = nil) {
        resetWeeklyWorkoutsIfNeeded()

        // Only count first workout of the day
        let shouldCount = isFirstWorkout ?? isFirstWorkoutOfDay
        guard shouldCount else { return }

        daysWorkedOutThisWeek += 1

        // Check if we met the weekly goal
        if daysWorkedOutThisWeek >= weeklyWorkoutGoal {
            let calendar = Calendar.current
            let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()

            // Only update streak once per week
            if lastWeekCompleted == nil || !calendar.isDate(lastWeekCompleted!, equalTo: currentWeekStart, toGranularity: .weekOfYear) {
                // Check if last completed week was the previous week
                if let lastCompleted = lastWeekCompleted {
                    let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)!
                    if calendar.isDate(lastCompleted, equalTo: previousWeekStart, toGranularity: .weekOfYear) {
                        // Consecutive week - increment streak
                        currentWeeklyStreak += 1
                    } else {
                        // Streak broken - reset to 1
                        currentWeeklyStreak = 1
                    }
                } else {
                    // First time meeting goal
                    currentWeeklyStreak = 1
                }

                lastWeekCompleted = currentWeekStart

                if currentWeeklyStreak > highestWeeklyStreak {
                    highestWeeklyStreak = currentWeeklyStreak
                }
            }
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
