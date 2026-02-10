import SwiftUI

struct PlanDayRow: View {
    let day: PlannedDay
    let isToday: Bool
    let isDayCompleted: Bool
    let completedExerciseNames: Set<String>
    let onExerciseTap: (PlannedExercise) -> Void

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if day.isRestDay {
                restDayRow
            } else {
                workoutDayHeader
                if isExpanded {
                    exerciseList
                }
            }
        }
        .onAppear {
            if isToday && !isDayCompleted {
                isExpanded = true
            }
        }
    }

    // MARK: - Rest Day

    private var restDayRow: some View {
        HStack(spacing: PixelScale.px(2)) {
            PixelText(day.label, size: .small, color: PixelTheme.textSecondary)
            PixelText("·", size: .small, color: PixelTheme.textSecondary)
            PixelText("REST", size: .small, color: PixelTheme.textSecondary)
            Spacer()
        }
        .padding(.vertical, PixelScale.px(1))
    }

    // MARK: - Workout Day Header

    private var workoutDayHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: PixelScale.px(2)) {
                // Expand/collapse indicator
                PixelText(isExpanded ? "▾" : "▸", size: .small, uppercase: false)

                // Day label
                PixelText(day.label, size: .small,
                         color: isToday ? PixelTheme.text : PixelTheme.text)

                PixelText("·", size: .small, color: PixelTheme.textSecondary)

                // Theme
                PixelText(day.theme, size: .small,
                         color: isDayCompleted ? PixelTheme.textSecondary : PixelTheme.text)

                Spacer()

                if isDayCompleted {
                    PixelIconView(icon: .check, size: 12)
                }
            }
            .padding(.vertical, PixelScale.px(1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(spacing: 0) {
            ForEach(day.exercises) { exercise in
                PlanExerciseRow(
                    exercise: exercise,
                    isCompleted: completedExerciseNames.contains(exercise.templateName),
                    onTap: { onExerciseTap(exercise) }
                )
                .padding(.leading, PixelScale.px(4))
            }
        }
    }
}
