import SwiftUI

struct WeeklyStreakBadge: View {
    let workoutsCompleted: Int
    let weeklyGoal: Int
    let currentStreak: Int
    let highestStreak: Int
    var compact: Bool = false

    private var hasMetGoal: Bool {
        workoutsCompleted >= weeklyGoal
    }

    var body: some View {
        VStack(spacing: compact ? 8 : 12) {
            // Weekly progress dots
            HStack(spacing: 6) {
                ForEach(0..<weeklyGoal, id: \.self) { index in
                    Circle()
                        .fill(index < workoutsCompleted ? Theme.primaryGradient : Theme.elevated.opacity(0.5))
                        .frame(width: compact ? 10 : 14, height: compact ? 10 : 14)
                        .overlay(
                            Circle()
                                .stroke(index < workoutsCompleted ? Color.clear : Theme.textMuted.opacity(0.3), lineWidth: 1)
                        )
                }

                Spacer()

                // Progress text
                Text("\(workoutsCompleted)/\(weeklyGoal)")
                    .font(.system(size: compact ? 12 : 14, weight: .semibold, design: .rounded))
                    .foregroundColor(hasMetGoal ? Theme.success : Theme.textSecondary)
            }

            // Progress message
            if !compact {
                Text(StreakManager.weeklyProgressText(completed: workoutsCompleted, goal: weeklyGoal))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(hasMetGoal ? Theme.success : Theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
                .background(Theme.elevated)

            // Streak info
            HStack(spacing: compact ? 12 : 20) {
                // Current weekly streak
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: compact ? 14 : 16))
                        .foregroundStyle(Theme.streakGradient)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(currentStreak)")
                            .font(.system(size: compact ? 18 : 22, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)

                        if !compact {
                            Text("week streak")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                }

                Spacer()

                // Highest streak
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: compact ? 12 : 14))
                        .foregroundColor(Theme.warning)

                    Text("\(highestStreak)")
                        .font(.system(size: compact ? 16 : 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.textSecondary)

                    if !compact {
                        Text("best")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Theme.textMuted)
                    }
                }
            }
        }
        .padding(compact ? 12 : 16)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        WeeklyStreakBadge(
            workoutsCompleted: 2,
            weeklyGoal: 4,
            currentStreak: 3,
            highestStreak: 8
        )

        WeeklyStreakBadge(
            workoutsCompleted: 4,
            weeklyGoal: 4,
            currentStreak: 5,
            highestStreak: 8
        )

        WeeklyStreakBadge(
            workoutsCompleted: 2,
            weeklyGoal: 4,
            currentStreak: 3,
            highestStreak: 8,
            compact: true
        )
    }
    .padding()
    .background(Theme.background)
}
