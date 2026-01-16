import Foundation

struct XPCalculator {

    /// Base XP values for pre-filled workouts
    /// Cardio = full session (150-250 XP), Strength = individual exercise (30-50 XP)
    static let baseXPValues: [String: Int] = [
        // Cardio (high XP - represents full workout session)
        "Run": 200,
        "Walk": 120,
        "Cycling": 175,
        "Swimming": 225,
        "Stair Climber": 200,

        // Chest
        "Barbell Bench Press": 45,
        "Dumbbell Bench Press": 40,
        "Incline Bench Press": 40,
        "Chest Fly": 35,

        // Back
        "Lat Pulldown": 40,
        "Seated Row": 40,
        "Pull-ups": 45,

        // Shoulders
        "Shoulder Press": 40,
        "Lateral Raises": 30,

        // Biceps
        "Barbell Curl": 30,
        "Dumbbell Curl": 30,

        // Triceps
        "Triceps Pushdown": 30,
        "Overhead Triceps Extension": 30,

        // Legs
        "Squats": 50,
        "Leg Press": 45,
        "Leg Extensions": 35,
        "Leg Curls": 35,
        "Lunges": 40,
        "Deadlift": 50,

        // Core
        "Plank": 30,
        "Cable Crunch": 30,
        "Russian Twists": 30
    ]

    /// Default base XP for custom workouts
    static let defaultBaseXP = 35

    /// First workout of the day bonus
    static let dailyBonusXP = 25

    /// Get base XP for a workout name
    static func baseXP(for workoutName: String) -> Int {
        baseXPValues[workoutName] ?? defaultBaseXP
    }

    /// Calculate XP for a strength workout
    static func calculateStrengthXP(
        baseXP: Int,
        weight: Double,
        reps: Int,
        sets: Int
    ) -> Int {
        let volumeScore = (weight * Double(reps * sets)) / 1000.0
        let volumeMultiplier = 1.0 + min(volumeScore, 2.0)
        return Int(Double(baseXP) * volumeMultiplier)
    }

    /// Calculate XP for a cardio workout
    static func calculateCardioXP(
        baseXP: Int,
        durationMinutes: Int,
        steps: Int? = nil,
        calories: Int? = nil
    ) -> Int {
        let durationMultiplier = 1.0 + (Double(durationMinutes) / 60.0)
        let intensityBonus = calories.map { Double($0) / 200.0 } ?? 0
        let total = Double(baseXP) * durationMultiplier + intensityBonus
        return Int(min(total, Double(baseXP) * 5))
    }

    /// Streak bonus multiplier
    static func streakMultiplier(streak: Int) -> Double {
        switch streak {
        case 0...2: return 1.0
        case 3...6: return 1.1
        case 7...13: return 1.25
        case 14...29: return 1.5
        default: return 2.0
        }
    }

    /// Get streak bonus description
    static func streakBonusDescription(streak: Int) -> String? {
        let multiplier = streakMultiplier(streak: streak)
        guard multiplier > 1.0 else { return nil }
        let percentage = Int((multiplier - 1.0) * 100)
        return "+\(percentage)% streak bonus"
    }

    /// Calculate total XP with all bonuses
    static func calculateTotalXP(
        baseXP: Int,
        workoutType: WorkoutType,
        streak: Int,
        isFirstWorkoutOfDay: Bool,
        weight: Double? = nil,
        reps: Int? = nil,
        sets: Int? = nil,
        durationMinutes: Int? = nil,
        steps: Int? = nil,
        calories: Int? = nil
    ) -> Int {
        var xp: Int

        switch workoutType {
        case .strength:
            xp = calculateStrengthXP(
                baseXP: baseXP,
                weight: weight ?? 0,
                reps: reps ?? 0,
                sets: sets ?? 0
            )
        case .cardio:
            xp = calculateCardioXP(
                baseXP: baseXP,
                durationMinutes: durationMinutes ?? 0,
                steps: steps,
                calories: calories
            )
        }

        // Apply streak multiplier
        xp = Int(Double(xp) * streakMultiplier(streak: streak))

        // Add daily bonus
        if isFirstWorkoutOfDay {
            xp += dailyBonusXP
        }

        return xp
    }
}
