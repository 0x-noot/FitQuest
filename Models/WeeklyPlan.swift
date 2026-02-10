import Foundation

// MARK: - Weekly Plan Value Types

struct PlannedExercise: Identifiable {
    let id = UUID()
    let templateName: String
    let workoutType: WorkoutType
    let muscleGroup: MuscleGroup?
    let iconName: String
    let baseXP: Int
}

struct PlannedDay: Identifiable {
    let id = UUID()
    let dayOfWeek: Int        // 1=Sun, 2=Mon ... 7=Sat (Calendar standard)
    let label: String         // "MON", "TUE", etc.
    let exercises: [PlannedExercise]
    let isRestDay: Bool
    let theme: String         // "CHEST + TRI", "CARDIO", "REST"
}

struct WeeklyPlan {
    let days: [PlannedDay]    // Always 7 entries, Sun-Sat
    let workoutDayCount: Int

    var workoutDays: [PlannedDay] {
        days.filter { !$0.isRestDay }
    }
}
