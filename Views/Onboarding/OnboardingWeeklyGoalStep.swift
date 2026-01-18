import SwiftUI

struct OnboardingWeeklyGoalStep: View {
    @Binding var weeklyGoal: Int
    let onContinue: () -> Void

    private var encouragingText: String {
        switch weeklyGoal {
        case 2:
            return "A great starting point! Consistency beats intensity."
        case 3:
            return "Perfect for building a sustainable habit."
        case 4:
            return "Solid commitment! You'll see steady progress."
        case 5:
            return "Impressive dedication! Great for faster results."
        case 6:
            return "High achiever mode! Make sure to rest."
        case 7:
            return "Beast mode! Remember recovery is important."
        default:
            return "Set your weekly workout target."
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Set your weekly goal")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("How many days per week do you want to work out?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            Spacer()

            // Goal display
            VStack(spacing: 16) {
                Text("\(weeklyGoal)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryGradient)

                Text("days per week")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }

            // Slider
            VStack(spacing: 12) {
                HStack {
                    Text("2")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                    Spacer()
                    Text("7")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }

                Slider(value: Binding(
                    get: { Double(weeklyGoal) },
                    set: { weeklyGoal = Int($0) }
                ), in: 2...7, step: 1)
                .tint(Theme.primary)
            }
            .padding(.horizontal, 20)

            // Encouraging text
            Text(encouragingText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.cardBackground)
                .cornerRadius(12)

            Spacer()

            // Continue button
            PrimaryButton("Continue", icon: "arrow.right") {
                onContinue()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    OnboardingWeeklyGoalStep(
        weeklyGoal: .constant(4)
    ) {}
    .background(Theme.background)
}
