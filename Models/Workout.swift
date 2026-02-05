import SwiftData
import Foundation

@Model
final class Workout {
    var id: UUID = UUID()
    var name: String = ""
    var workoutTypeRaw: String = "strength"
    var completedAt: Date = Date()
    var xpEarned: Int = 0

    // Strength training fields
    var weight: Double?
    var reps: Int?
    var sets: Int?

    // Cardio fields
    var steps: Int?
    var durationMinutes: Int?
    var caloriesBurned: Int?

    // Walking-specific fields
    var incline: Double?      // Treadmill incline percentage (0-15)
    var speed: Double?        // Walking speed in mph (1.0-5.0)

    // Relationships
    var player: Player?
    @Relationship(inverse: \WorkoutTemplate.workouts)
    var template: WorkoutTemplate?

    var workoutType: WorkoutType {
        get { WorkoutType(rawValue: workoutTypeRaw) ?? .strength }
        set { workoutTypeRaw = newValue.rawValue }
    }

    init(
        name: String,
        workoutType: WorkoutType,
        xpEarned: Int,
        weight: Double? = nil,
        reps: Int? = nil,
        sets: Int? = nil,
        steps: Int? = nil,
        durationMinutes: Int? = nil,
        caloriesBurned: Int? = nil,
        incline: Double? = nil,
        speed: Double? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.workoutTypeRaw = workoutType.rawValue
        self.completedAt = Date()
        self.xpEarned = xpEarned
        self.weight = weight
        self.reps = reps
        self.sets = sets
        self.steps = steps
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.incline = incline
        self.speed = speed
    }

    /// Formatted display of workout details
    var detailsText: String {
        switch workoutType {
        case .strength:
            guard let weight = weight, let reps = reps, let sets = sets else {
                return ""
            }
            return "\(Int(weight)) lbs \u{2022} \(sets)\u{00D7}\(reps)"

        case .cardio:
            var parts: [String] = []
            if let duration = durationMinutes {
                parts.append("\(duration) min")
            }
            // Show incline/speed for walking workouts
            if name == "Walk" {
                if let inclineValue = incline, inclineValue > 0 {
                    parts.append("\(String(format: "%.1f", inclineValue))% incline")
                }
                if let speedValue = speed {
                    parts.append("\(String(format: "%.1f", speedValue)) mph")
                }
            }
            if let steps = steps {
                parts.append("\(steps.formatted()) steps")
            }
            if let calories = caloriesBurned {
                parts.append("\(calories) cal")
            }
            return parts.joined(separator: " \u{2022} ")
        }
    }

    /// Volume for strength workouts (weight × reps × sets)
    var volume: Double? {
        guard workoutType == .strength,
              let weight = weight,
              let reps = reps,
              let sets = sets else {
            return nil
        }
        return weight * Double(reps * sets)
    }
}
