import SwiftData
import Foundation

@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var workoutTypeRaw: String
    var muscleGroupRaw: String?
    var isCustom: Bool
    var iconName: String
    var baseXP: Int
    var createdAt: Date

    // Default values for quick entry
    var defaultWeight: Double?
    var defaultReps: Int?
    var defaultSets: Int?
    var defaultDuration: Int?

    var workoutType: WorkoutType {
        get { WorkoutType(rawValue: workoutTypeRaw) ?? .strength }
        set { workoutTypeRaw = newValue.rawValue }
    }

    var muscleGroup: MuscleGroup? {
        get { muscleGroupRaw.flatMap { MuscleGroup(rawValue: $0) } }
        set { muscleGroupRaw = newValue?.rawValue }
    }

    init(
        name: String,
        workoutType: WorkoutType,
        muscleGroup: MuscleGroup? = nil,
        isCustom: Bool = false,
        iconName: String = "figure.walk",
        baseXP: Int = 50
    ) {
        self.id = UUID()
        self.name = name
        self.workoutTypeRaw = workoutType.rawValue
        self.muscleGroupRaw = muscleGroup?.rawValue
        self.isCustom = isCustom
        self.iconName = iconName
        self.baseXP = baseXP
        self.createdAt = Date()
    }

    /// Create all default workout templates
    static func createDefaults() -> [WorkoutTemplate] {
        [
            // Cardio
            WorkoutTemplate(name: "Run", workoutType: .cardio, iconName: "figure.run", baseXP: 80),
            WorkoutTemplate(name: "Walk", workoutType: .cardio, iconName: "figure.walk", baseXP: 40),
            WorkoutTemplate(name: "Cycling", workoutType: .cardio, iconName: "figure.outdoor.cycle", baseXP: 70),
            WorkoutTemplate(name: "Swimming", workoutType: .cardio, iconName: "figure.pool.swim", baseXP: 90),

            // Strength
            WorkoutTemplate(name: "Squats", workoutType: .strength, muscleGroup: .legs, iconName: "figure.strengthtraining.traditional", baseXP: 60),
            WorkoutTemplate(name: "Deadlifts", workoutType: .strength, muscleGroup: .back, iconName: "figure.strengthtraining.functional", baseXP: 75),
            WorkoutTemplate(name: "Bench Press", workoutType: .strength, muscleGroup: .chest, iconName: "dumbbell.fill", baseXP: 70),
            WorkoutTemplate(name: "Pull-ups", workoutType: .strength, muscleGroup: .back, iconName: "figure.climbing", baseXP: 65),
            WorkoutTemplate(name: "Push-ups", workoutType: .strength, muscleGroup: .chest, iconName: "figure.strengthtraining.traditional", baseXP: 50),
            WorkoutTemplate(name: "Planks", workoutType: .strength, muscleGroup: .core, iconName: "figure.core.training", baseXP: 45)
        ]
    }
}
