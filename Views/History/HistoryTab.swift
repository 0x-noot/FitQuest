import SwiftUI
import SwiftData

// MARK: - History Tab (Pixel Art Style)

struct HistoryTab: View {
    @Bindable var player: Player

    private var recentWorkouts: [Workout] {
        (player.workouts ?? []).sorted { $0.completedAt > $1.completedAt }
    }

    private var totalXPEarned: Int {
        (player.workouts ?? []).reduce(0) { $0 + $1.xpEarned }
    }

    private var totalWorkouts: Int {
        (player.workouts ?? []).count
    }

    private var xpThisWeek: Int {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        return (player.workouts ?? [])
            .filter { $0.completedAt >= weekStart }
            .reduce(0) { $0 + $1.xpEarned }
    }

    var body: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Title bar
            HStack {
                PixelText("HISTORY", size: .large)
                Spacer()
            }
            .padding(.horizontal, PixelScale.px(2))
            .padding(.top, PixelScale.px(2))

            // This week panel
            thisWeekPanel
                .padding(.horizontal, PixelScale.px(2))

            // Stats row
            HStack(spacing: PixelScale.px(2)) {
                PixelStatBox(value: "\(totalWorkouts)", label: "TOTAL")
                PixelStatBox(value: formatXP(totalXPEarned), label: "XP")
            }
            .padding(.horizontal, PixelScale.px(2))

            // Recent workouts
            PixelPanel(title: "RECENT") {
                if recentWorkouts.isEmpty {
                    VStack(spacing: PixelScale.px(2)) {
                        PixelIconView(icon: .scroll, size: 24)
                        PixelText("NO WORKOUTS YET", size: .small, color: PixelTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PixelScale.px(4))
                } else {
                    VStack(spacing: PixelScale.px(1)) {
                        ForEach(recentWorkouts.prefix(5)) { workout in
                            PixelWorkoutRow(workout: workout)
                        }
                    }
                }
            }
            .padding(.horizontal, PixelScale.px(2))

            Spacer()
        }
        .background(PixelTheme.background)
    }

    // MARK: - This Week Panel

    private var thisWeekPanel: some View {
        PixelPanel(title: "THIS WEEK") {
            VStack(spacing: PixelScale.px(2)) {
                // Weekly progress bar
                PixelWeeklyBar(
                    daysCompleted: player.daysWorkedOutThisWeek,
                    goal: player.weeklyWorkoutGoal
                )

                // XP and streak
                HStack {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .bolt, size: 12)
                        PixelText("\(xpThisWeek) XP", size: .small)
                    }

                    Spacer()

                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .flame, size: 12)
                        PixelText("\(player.currentStreak) STREAK", size: .small)
                    }
                }

                // Rest day / streak freeze
                if player.currentStreak > 0 {
                    Rectangle()
                        .fill(PixelTheme.border.opacity(0.3))
                        .frame(height: PixelScale.px(1))

                    RestDayButton(player: player)
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatXP(_ xp: Int) -> String {
        if xp >= 1000 {
            return String(format: "%.1fK", Double(xp) / 1000.0)
        }
        return "\(xp)"
    }
}

// MARK: - Pixel Workout Row

struct PixelWorkoutRow: View {
    let workout: Workout

    private var dateText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(workout.completedAt) {
            return "TODAY"
        } else if calendar.isDateInYesterday(workout.completedAt) {
            return "YESTERDAY"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: workout.completedAt).uppercased()
        }
    }

    var body: some View {
        HStack(spacing: PixelScale.px(2)) {
            // Icon
            PixelIconView(
                icon: workout.workoutType == .cardio ? .run : .dumbbell,
                size: 12
            )

            // Name (truncated)
            PixelText(
                String(workout.name.prefix(10)).uppercased(),
                size: .small
            )

            Spacer()

            // Date
            PixelText(dateText, size: .small, color: PixelTheme.textSecondary)

            // XP
            PixelText("+\(workout.xpEarned)", size: .small)
        }
        .padding(.vertical, PixelScale.px(1))
    }
}

// MARK: - Pixel Weekly Summary Card

struct PixelWeeklySummaryCard: View {
    let daysWorkedOutThisWeek: Int
    let weeklyGoal: Int
    let xpThisWeek: Int
    let currentStreak: Int

    var body: some View {
        PixelPanel(title: "WEEKLY GOAL") {
            VStack(spacing: PixelScale.px(2)) {
                PixelWeeklyBar(daysCompleted: daysWorkedOutThisWeek, goal: weeklyGoal)

                HStack {
                    PixelText("XP: \(xpThisWeek)", size: .small)
                    Spacer()
                    PixelText("STREAK: \(currentStreak)", size: .small)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryTab(player: {
        let p = Player(name: "Test")
        p.daysWorkedOutThisWeek = 3
        p.weeklyWorkoutGoal = 5
        p.currentStreak = 7
        p.workouts = [
            Workout(name: "Running", workoutType: .cardio, xpEarned: 156, durationMinutes: 30),
            Workout(name: "Bench Press", workoutType: .strength, xpEarned: 142, weight: 135, reps: 10, sets: 3)
        ]
        return p
    }())
    .modelContainer(for: [Player.self, Workout.self], inMemory: true)
}
