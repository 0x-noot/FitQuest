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
        calories: Int? = nil,
        incline: Double? = nil,
        speed: Double? = nil
    ) -> Int {
        let durationMultiplier = 1.0 + (Double(durationMinutes) / 60.0)
        let intensityBonus = calories.map { Double($0) / 200.0 } ?? 0

        // Walking intensity bonus based on incline and speed
        var walkingIntensityMultiplier = 1.0
        if let inclineValue = incline, inclineValue > 0 {
            // Each 1% incline adds 5% XP bonus (max 75% at 15% incline)
            walkingIntensityMultiplier += min(inclineValue * 0.05, 0.75)
        }
        if let speedValue = speed {
            // Speed bonus: 2.0 mph = baseline, each 0.5 mph above adds 10% (max 60% at 5.0 mph)
            let speedBonus = max(0, (speedValue - 2.0) / 0.5 * 0.10)
            walkingIntensityMultiplier += min(speedBonus, 0.60)
        }

        let total = Double(baseXP) * durationMultiplier * walkingIntensityMultiplier + intensityBonus
        return Int(min(total, Double(baseXP) * 5))
    }

    /// Calculate walking XP with detailed intensity breakdown
    static func calculateWalkingIntensityBonus(incline: Double?, speed: Double?) -> (inclineBonus: Int, speedBonus: Int) {
        var inclineBonus = 0
        var speedBonus = 0

        if let inclineValue = incline, inclineValue > 0 {
            inclineBonus = Int(min(inclineValue * 5, 75))
        }
        if let speedValue = speed, speedValue > 2.0 {
            speedBonus = Int(min((speedValue - 2.0) / 0.5 * 10, 60))
        }

        return (inclineBonus, speedBonus)
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

    /// Calculate total XP with all bonuses (including pet bonuses)
    static func calculateTotalXP(
        baseXP: Int,
        workoutType: WorkoutType,
        streak: Int,
        isFirstWorkoutOfDay: Bool,
        pet: Pet? = nil,
        weight: Double? = nil,
        reps: Int? = nil,
        sets: Int? = nil,
        durationMinutes: Int? = nil,
        steps: Int? = nil,
        calories: Int? = nil,
        incline: Double? = nil,
        speed: Double? = nil
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
                calories: calories,
                incline: incline,
                speed: speed
            )
        }

        // Apply pet species/level bonus FIRST (if pet is active)
        if let pet = pet, !pet.isAway {
            let petMultiplier = pet.species.xpMultiplier(for: workoutType, petLevel: pet.currentLevel)
            xp = Int(Double(xp) * petMultiplier)
        }

        // Apply streak multiplier
        xp = Int(Double(xp) * streakMultiplier(streak: streak))

        // Apply happiness bonus (if pet is active and happy enough)
        if let pet = pet, !pet.isAway {
            let happinessMultiplier = PetManager.happinessXPMultiplier(happiness: pet.happiness)
            xp = Int(Double(xp) * happinessMultiplier)
        }

        // Add daily bonus
        if isFirstWorkoutOfDay {
            xp += dailyBonusXP
        }

        return xp
    }

    /// Get pet bonus description for display
    static func petBonusDescription(pet: Pet?, workoutType: WorkoutType) -> String? {
        guard let pet = pet, !pet.isAway else { return nil }

        var bonuses: [String] = []

        // Species/level bonus
        let speciesMultiplier = pet.species.xpMultiplier(for: workoutType, petLevel: pet.currentLevel)
        if speciesMultiplier > 1.0 {
            let percentage = Int((speciesMultiplier - 1.0) * 100)
            bonuses.append("+\(percentage)% \(pet.species.displayName) Lv\(pet.currentLevel)")
        }

        // Happiness bonus
        if PetManager.hasXPBonus(happiness: pet.happiness) {
            bonuses.append("+10% happiness")
        }

        return bonuses.isEmpty ? nil : bonuses.joined(separator: ", ")
    }
}
