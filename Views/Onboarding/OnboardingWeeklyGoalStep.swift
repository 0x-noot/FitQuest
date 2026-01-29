import SwiftUI

struct OnboardingWeeklyGoalStep: View {
    @Binding var weeklyGoal: Int
    let onContinue: () -> Void

    private var encouragingText: String {
        switch weeklyGoal {
        case 2:
            return "GREAT START! CONSISTENCY > INTENSITY"
        case 3:
            return "PERFECT FOR A SUSTAINABLE HABIT"
        case 4:
            return "SOLID! YOU'LL SEE STEADY PROGRESS"
        case 5:
            return "IMPRESSIVE! GREAT FOR RESULTS"
        case 6:
            return "HIGH ACHIEVER! DON'T FORGET REST"
        case 7:
            return "BEAST MODE! RECOVERY IS KEY"
        default:
            return "SET YOUR WEEKLY TARGET"
        }
    }

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            // Header
            VStack(spacing: PixelScale.px(1)) {
                PixelText("WEEKLY GOAL", size: .xlarge)
                PixelText("HOW MANY DAYS PER WEEK?", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(.top, PixelScale.px(2))

            Spacer()

            // Goal display
            VStack(spacing: PixelScale.px(2)) {
                PixelText("\(weeklyGoal)", size: .xlarge)
                    .scaleEffect(2.0)
                    .padding(.vertical, PixelScale.px(4))

                PixelText("DAYS PER WEEK", size: .medium, color: PixelTheme.textSecondary)
            }

            // Stepper controls (pixel style)
            HStack(spacing: PixelScale.px(4)) {
                PixelButton("-", style: .secondary) {
                    if weeklyGoal > 2 {
                        weeklyGoal -= 1
                    }
                }
                .frame(width: PixelScale.px(12))

                PixelProgressBar(
                    progress: Double(weeklyGoal - 2) / 5.0,
                    segments: 6
                )

                PixelButton("+", style: .secondary) {
                    if weeklyGoal < 7 {
                        weeklyGoal += 1
                    }
                }
                .frame(width: PixelScale.px(12))
            }
            .padding(.horizontal, PixelScale.px(4))

            // Encouraging text
            PixelPanel(title: "TIP") {
                PixelText(encouragingText, size: .small, color: PixelTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, PixelScale.px(4))

            Spacer()

            // Continue button
            PixelButton("CONTINUE >", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, PixelScale.px(4))
        }
        .padding(.vertical, PixelScale.px(4))
    }
}

#Preview {
    OnboardingWeeklyGoalStep(
        weeklyGoal: .constant(4)
    ) {}
    .background(PixelTheme.background)
}
