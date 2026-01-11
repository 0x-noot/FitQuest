import SwiftUI
import SwiftData
import Observation

@Observable
class WorkoutViewModel {
    private var modelContext: ModelContext
    private var player: Player

    // Workout input state
    var selectedTemplate: WorkoutTemplate?
    var workoutName: String = ""
    var workoutType: WorkoutType = .strength

    // Strength inputs
    var weight: Double = 135
    var reps: Int = 10
    var sets: Int = 3

    // Cardio inputs
    var durationMinutes: Int = 30
    var steps: Int? = nil
    var caloriesBurned: Int? = nil

    // Custom workout
    var muscleGroup: MuscleGroup = .fullBody
    var saveAsTemplate: Bool = false

    init(player: Player, modelContext: ModelContext) {
        self.player = player
        self.modelContext = modelContext
    }

    var estimatedXP: Int {
        let baseXP = selectedTemplate?.baseXP ?? XPCalculator.defaultBaseXP

        return XPCalculator.calculateTotalXP(
            baseXP: baseXP,
            workoutType: workoutType,
            streak: player.currentStreak,
            isFirstWorkoutOfDay: player.isFirstWorkoutOfDay,
            weight: workoutType == .strength ? weight : nil,
            reps: workoutType == .strength ? reps : nil,
            sets: workoutType == .strength ? sets : nil,
            durationMinutes: workoutType == .cardio ? durationMinutes : nil,
            steps: steps,
            calories: caloriesBurned
        )
    }

    var streakBonusText: String? {
        XPCalculator.streakBonusDescription(streak: player.currentStreak)
    }

    func selectTemplate(_ template: WorkoutTemplate) {
        selectedTemplate = template
        workoutName = template.name
        workoutType = template.workoutType

        // Apply defaults if available
        if let defaultWeight = template.defaultWeight {
            weight = defaultWeight
        }
        if let defaultReps = template.defaultReps {
            reps = defaultReps
        }
        if let defaultSets = template.defaultSets {
            sets = defaultSets
        }
        if let defaultDuration = template.defaultDuration {
            durationMinutes = defaultDuration
        }
    }

    func createWorkout() -> Workout {
        let xp = estimatedXP

        let workout: Workout
        if workoutType == .strength {
            workout = Workout(
                name: workoutName.isEmpty ? "Workout" : workoutName,
                workoutType: workoutType,
                xpEarned: xp,
                weight: weight,
                reps: reps,
                sets: sets
            )
        } else {
            workout = Workout(
                name: workoutName.isEmpty ? "Workout" : workoutName,
                workoutType: workoutType,
                xpEarned: xp,
                steps: steps,
                durationMinutes: durationMinutes,
                caloriesBurned: caloriesBurned
            )
        }

        workout.template = selectedTemplate

        // Save as custom template if requested
        if saveAsTemplate && selectedTemplate == nil {
            let template = WorkoutTemplate(
                name: workoutName,
                workoutType: workoutType,
                muscleGroup: workoutType == .strength ? muscleGroup : nil,
                isCustom: true,
                iconName: workoutType == .cardio ? "figure.run" : "dumbbell.fill",
                baseXP: XPCalculator.defaultBaseXP
            )
            template.defaultWeight = workoutType == .strength ? weight : nil
            template.defaultReps = workoutType == .strength ? reps : nil
            template.defaultSets = workoutType == .strength ? sets : nil
            template.defaultDuration = workoutType == .cardio ? durationMinutes : nil
            modelContext.insert(template)
        }

        return workout
    }

    func reset() {
        selectedTemplate = nil
        workoutName = ""
        workoutType = .strength
        weight = 135
        reps = 10
        sets = 3
        durationMinutes = 30
        steps = nil
        caloriesBurned = nil
        muscleGroup = .fullBody
        saveAsTemplate = false
    }
}
