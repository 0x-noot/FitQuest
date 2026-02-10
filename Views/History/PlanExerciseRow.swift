import SwiftUI

struct PlanExerciseRow: View {
    let exercise: PlannedExercise
    let isCompleted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PixelScale.px(2)) {
                // Checkmark or empty box
                if isCompleted {
                    PixelIconView(icon: .check, size: 12)
                } else {
                    Rectangle()
                        .fill(PixelTheme.cardBackground)
                        .frame(width: PixelScale.px(3), height: PixelScale.px(3))
                        .pixelOutline()
                }

                // Exercise name
                PixelText(
                    exercise.templateName.uppercased(),
                    size: .small,
                    color: isCompleted ? PixelTheme.textSecondary : PixelTheme.text
                )
                .strikethrough(isCompleted)

                Spacer()

                // Base XP
                PixelText(
                    "\(exercise.baseXP)XP",
                    size: .small,
                    color: PixelTheme.textSecondary
                )
            }
            .padding(.vertical, PixelScale.px(1))
            .padding(.horizontal, PixelScale.px(1))
        }
        .buttonStyle(.plain)
        .opacity(isCompleted ? 0.6 : 1.0)
    }
}
