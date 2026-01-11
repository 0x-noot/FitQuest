import SwiftData
import Foundation

@Model
final class Workout {
    var id: UUID
    var name: String
    var workoutTypeRaw: String
    var completedAt: Date
    var xpEarned: Int

    // Strength training fields
    var weight: Double?
    var reps: Int?
    var sets: Int?

    // Cardio fields
    var steps: Int?
    var durationMinutes: Int?
    var caloriesBurned: Int?

    // Relationships
    var player: Player?
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
        caloriesBurned: Int? = nil
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
