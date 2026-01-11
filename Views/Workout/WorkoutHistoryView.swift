import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Bindable var player: Player

    private var groupedWorkouts: [(String, [Workout])] {
        let calendar = Calendar.current
        let sorted = player.workouts.sorted { $0.completedAt > $1.completedAt }

        var groups: [String: [Workout]] = [:]
        let formatter = DateFormatter()

        for workout in sorted {
            let dateKey: String
            if calendar.isDateInToday(workout.completedAt) {
                dateKey = "Today"
            } else if calendar.isDateInYesterday(workout.completedAt) {
                dateKey = "Yesterday"
            } else {
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                dateKey = formatter.string(from: workout.completedAt)
            }

            groups[dateKey, default: []].append(workout)
        }

        // Sort groups by date (Today first, then Yesterday, then by date descending)
        let sortedKeys = groups.keys.sorted { key1, key2 in
            if key1 == "Today" { return true }
            if key2 == "Today" { return false }
            if key1 == "Yesterday" { return true }
            if key2 == "Yesterday" { return false }
            return key1 > key2
        }

        return sortedKeys.map { ($0, groups[$0]!) }
    }

    private var weeklyStats: (workouts: Int, xp: Int) {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!

        let thisWeekWorkouts = player.workouts.filter { $0.completedAt >= startOfWeek }
        let totalXP = thisWeekWorkouts.reduce(0) { $0 + $1.xpEarned }

        return (thisWeekWorkouts.count, totalXP)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weekly summary
                weeklyCard

                // Workouts by date
                if groupedWorkouts.isEmpty {
                    emptyState
                } else {
                    ForEach(groupedWorkouts, id: \.0) { dateKey, workouts in
                        workoutSection(title: dateKey, workouts: workouts)
                    }
                }
            }
            .padding(20)
        }
        .background(Theme.background)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.cardBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var weeklyCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("This Week")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textMuted)

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Text("\(weeklyStats.workouts)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        Text("workouts")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textSecondary)
                    }

                    HStack(spacing: 4) {
                        Text("+\(weeklyStats.xp.formatted())")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.success)
                        Text("XP")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 48))
                .foregroundColor(Theme.textMuted)

            Text("No workouts yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            Text("Complete your first workout to see it here!")
                .font(.system(size: 14))
                .foregroundColor(Theme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func workoutSection(title: String, workouts: [Workout]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .textCase(.uppercase)
                .tracking(1)

            ForEach(workouts) { workout in
                WorkoutHistoryRow(workout: workout)
            }
        }
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(workout.workoutType == .cardio ? Theme.secondary.opacity(0.2) : Theme.primary.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: workout.workoutType == .cardio ? "figure.run" : "dumbbell.fill")
                    .font(.system(size: 18))
                    .foregroundColor(workout.workoutType == .cardio ? Theme.secondary : Theme.primary)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text(workout.detailsText)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textMuted)
            }

            Spacer()

            // XP earned
            HStack(spacing: 4) {
                Text("+\(workout.xpEarned)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.success)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.warning)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        WorkoutHistoryView(player: {
            let p = Player()
            p.workouts = [
                Workout(name: "Running", workoutType: .cardio, xpEarned: 156, durationMinutes: 30, steps: 3500),
                Workout(name: "Bench Press", workoutType: .strength, xpEarned: 142, weight: 135, reps: 10, sets: 3),
                Workout(name: "Squats", workoutType: .strength, xpEarned: 168, weight: 185, reps: 8, sets: 4)
            ]
            return p
        }())
    }
}
