import SwiftUI

struct WeeklySummaryCard: View {
    let workoutsThisWeek: Int
    let xpThisWeek: Int
    let currentStreak: Int

    private var weekProgress: Double {
        // Progress based on a goal of 5 workouts per week
        min(Double(workoutsThisWeek) / 5.0, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.secondary)

                Text("THIS WEEK")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textMuted)
                    .tracking(1)

                Spacer()

                Text(weekDateRange)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted)
            }

            // Stats row
            HStack(spacing: 0) {
                // Workouts
                WeeklyStat(
                    value: "\(workoutsThisWeek)",
                    label: "Workouts",
                    icon: "figure.run",
                    color: Theme.primary
                )

                Divider()
                    .frame(height: 40)
                    .background(Theme.elevated)

                // XP Earned
                WeeklyStat(
                    value: xpThisWeek.formatted(),
                    label: "XP Earned",
                    icon: "bolt.fill",
                    color: Theme.success
                )

                Divider()
                    .frame(height: 40)
                    .background(Theme.elevated)

                // Streak
                WeeklyStat(
                    value: "\(currentStreak)",
                    label: "Day Streak",
                    icon: "flame.fill",
                    color: Theme.streak
                )
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Weekly Goal")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Spacer()

                    Text("\(workoutsThisWeek)/5 workouts")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(weekProgress >= 1.0 ? Theme.success : Theme.textMuted)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.elevated)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.secondary, Theme.primary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * weekProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }

            // Motivational message
            if workoutsThisWeek >= 5 {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.warning)
                    Text("Weekly goal achieved!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.warning)
                }
            } else if workoutsThisWeek > 0 {
                Text("\(5 - workoutsThisWeek) more workout\(5 - workoutsThisWeek == 1 ? "" : "s") to hit your goal!")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }

    private var weekDateRange: String {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
}

struct WeeklyStat: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)

                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
            }

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        WeeklySummaryCard(workoutsThisWeek: 3, xpThisWeek: 850, currentStreak: 5)
        WeeklySummaryCard(workoutsThisWeek: 5, xpThisWeek: 1250, currentStreak: 12)
        WeeklySummaryCard(workoutsThisWeek: 0, xpThisWeek: 0, currentStreak: 0)
    }
    .padding()
    .background(Color(red: 0.05, green: 0.05, blue: 0.06))
}
