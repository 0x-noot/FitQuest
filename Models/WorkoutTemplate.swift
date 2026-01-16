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
            // CARDIO (5 workouts) - High XP for full sessions
            WorkoutTemplate(name: "Run", workoutType: .cardio, iconName: "figure.run", baseXP: 200),
            WorkoutTemplate(name: "Walk", workoutType: .cardio, iconName: "figure.walk", baseXP: 120),
            WorkoutTemplate(name: "Cycling", workoutType: .cardio, iconName: "figure.outdoor.cycle", baseXP: 175),
            WorkoutTemplate(name: "Swimming", workoutType: .cardio, iconName: "figure.pool.swim", baseXP: 225),
            WorkoutTemplate(name: "Stair Climber", workoutType: .cardio, iconName: "figure.stair.stepper", baseXP: 200),

            // CHEST (4 workouts)
            WorkoutTemplate(name: "Barbell Bench Press", workoutType: .strength, muscleGroup: .chest, iconName: "dumbbell.fill", baseXP: 45),
            WorkoutTemplate(name: "Dumbbell Bench Press", workoutType: .strength, muscleGroup: .chest, iconName: "dumbbell.fill", baseXP: 40),
            WorkoutTemplate(name: "Incline Bench Press", workoutType: .strength, muscleGroup: .chest, iconName: "dumbbell.fill", baseXP: 40),
            WorkoutTemplate(name: "Chest Fly", workoutType: .strength, muscleGroup: .chest, iconName: "figure.arms.open", baseXP: 35),

            // BACK (3 workouts)
            WorkoutTemplate(name: "Lat Pulldown", workoutType: .strength, muscleGroup: .back, iconName: "figure.rowing", baseXP: 40),
            WorkoutTemplate(name: "Seated Row", workoutType: .strength, muscleGroup: .back, iconName: "figure.rowing", baseXP: 40),
            WorkoutTemplate(name: "Pull-ups", workoutType: .strength, muscleGroup: .back, iconName: "figure.climbing", baseXP: 45),

            // SHOULDERS (2 workouts)
            WorkoutTemplate(name: "Shoulder Press", workoutType: .strength, muscleGroup: .shoulders, iconName: "figure.arms.open", baseXP: 40),
            WorkoutTemplate(name: "Lateral Raises", workoutType: .strength, muscleGroup: .shoulders, iconName: "figure.arms.open", baseXP: 30),

            // BICEPS (2 workouts)
            WorkoutTemplate(name: "Barbell Curl", workoutType: .strength, muscleGroup: .biceps, iconName: "dumbbell.fill", baseXP: 30),
            WorkoutTemplate(name: "Dumbbell Curl", workoutType: .strength, muscleGroup: .biceps, iconName: "dumbbell.fill", baseXP: 30),

            // TRICEPS (2 workouts)
            WorkoutTemplate(name: "Triceps Pushdown", workoutType: .strength, muscleGroup: .triceps, iconName: "figure.strengthtraining.traditional", baseXP: 30),
            WorkoutTemplate(name: "Overhead Triceps Extension", workoutType: .strength, muscleGroup: .triceps, iconName: "dumbbell.fill", baseXP: 30),

            // LEGS (6 workouts)
            WorkoutTemplate(name: "Squats", workoutType: .strength, muscleGroup: .legs, iconName: "figure.strengthtraining.traditional", baseXP: 50),
            WorkoutTemplate(name: "Leg Press", workoutType: .strength, muscleGroup: .legs, iconName: "figure.strengthtraining.functional", baseXP: 45),
            WorkoutTemplate(name: "Leg Extensions", workoutType: .strength, muscleGroup: .legs, iconName: "figure.walk", baseXP: 35),
            WorkoutTemplate(name: "Leg Curls", workoutType: .strength, muscleGroup: .legs, iconName: "figure.walk", baseXP: 35),
            WorkoutTemplate(name: "Lunges", workoutType: .strength, muscleGroup: .legs, iconName: "figure.walk", baseXP: 40),
            WorkoutTemplate(name: "Deadlift", workoutType: .strength, muscleGroup: .legs, iconName: "figure.strengthtraining.functional", baseXP: 50),

            // CORE (3 workouts)
            WorkoutTemplate(name: "Plank", workoutType: .strength, muscleGroup: .core, iconName: "figure.core.training", baseXP: 30),
            WorkoutTemplate(name: "Cable Crunch", workoutType: .strength, muscleGroup: .core, iconName: "figure.core.training", baseXP: 30),
            WorkoutTemplate(name: "Russian Twists", workoutType: .strength, muscleGroup: .core, iconName: "figure.core.training", baseXP: 30)
        ]
    }
}
