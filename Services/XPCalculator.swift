import Foundation

struct XPCalculator {

    /// Base XP values for pre-filled workouts
    static let baseXPValues: [String: Int] = [
        // Cardio
        "Run": 80,
        "Walk": 40,
        "Cycling": 70,
        "Swimming": 90,

        // Strength
        "Squats": 60,
        "Deadlifts": 75,
        "Bench Press": 70,
        "Pull-ups": 65,
        "Push-ups": 50,
        "Planks": 45
    ]

    /// Default base XP for custom workouts
    static let defaultBaseXP = 50

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
