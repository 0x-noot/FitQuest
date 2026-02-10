import SwiftUI
import SwiftData

struct WeeklyPlanView: View {
    @Bindable var player: Player
    let templates: [WorkoutTemplate]
    let onExerciseTap: (PlannedExercise, WorkoutTemplate?) -> Void

    private var plan: WeeklyPlan {
        WorkoutPlanGenerator.generatePlan(player: player, templates: templates)
    }

    private var todayDayOfWeek: Int {
        Calendar.current.component(.weekday, from: Date()) // 1=Sun, 2=Mon ... 7=Sat
    }

    private var completedDayCount: Int {
        plan.workoutDays.filter { player.isPlanDayCompleted($0.label) }.count
    }

    /// Names of exercises completed today (from actual workout log)
    private var todaysCompletedExerciseNames: Set<String> {
        Set(player.todaysWorkouts.map { $0.name })
    }

    /// Whether any cardio workout was logged today
    private var didCardioToday: Bool {
        player.todaysWorkouts.contains { $0.workoutType == .cardio }
    }

    /// For cardio days, any cardio workout counts as completing all exercises
    private func completedExerciseNames(for day: PlannedDay) -> Set<String> {
        guard day.dayOfWeek == todayDayOfWeek else { return [] }
        if day.theme == "CARDIO" && didCardioToday {
            return Set(day.exercises.map { $0.templateName })
        }
        return todaysCompletedExerciseNames
    }

    var body: some View {
        PixelPanelWithCounter(
            title: "MY PLAN",
            current: completedDayCount,
            total: plan.workoutDayCount
        ) {
            VStack(spacing: PixelScale.px(1)) {
                ForEach(plan.days) { day in
                    PlanDayRow(
                        day: day,
                        isToday: day.dayOfWeek == todayDayOfWeek,
                        isDayCompleted: player.isPlanDayCompleted(day.label),
                        completedExerciseNames: completedExerciseNames(for: day),
                        onExerciseTap: { exercise in
                            let matchingTemplate = templates.first { $0.name == exercise.templateName }
                            onExerciseTap(exercise, matchingTemplate)
                        }
                    )

                    if day.dayOfWeek != 7 {
                        Rectangle()
                            .fill(PixelTheme.border.opacity(0.2))
                            .frame(height: PixelScale.px(0.5))
                    }
                }

                // Regenerate button
                PixelButton("REGENERATE", style: .secondary) {
                    player.planRegenerationCount += 1
                }
                .padding(.top, PixelScale.px(2))
            }
        }
    }
}
