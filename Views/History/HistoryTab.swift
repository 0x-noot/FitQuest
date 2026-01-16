import SwiftUI
import SwiftData

struct HistoryTab: View {
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

        let sortedKeys = groups.keys.sorted { key1, key2 in
            if key1 == "Today" { return true }
            if key2 == "Today" { return false }
            if key1 == "Yesterday" { return true }
            if key2 == "Yesterday" { return false }
            return key1 > key2
        }

        return sortedKeys.map { ($0, groups[$0]!) }
    }

    private var totalXPEarned: Int {
        player.workouts.reduce(0) { $0 + $1.xpEarned }
    }

    private var totalWorkouts: Int {
        player.workouts.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Calendar heatmap
                    CalendarHeatmapView(workouts: player.workouts)

                    // Stats summary
                    statsSummary

                    // Workout list
                    if groupedWorkouts.isEmpty {
                        emptyState
                    } else {
                        workoutList
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Theme.background)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var statsSummary: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Workouts",
                value: "\(totalWorkouts)",
                icon: "figure.run",
                color: Theme.primary
            )

            StatCard(
                title: "Total XP",
                value: totalXPEarned.formatted(),
                icon: "bolt.fill",
                color: Theme.success
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
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
        .padding(.vertical, 40)
    }

    private var workoutList: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("RECENT WORKOUTS")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .tracking(1)

            ForEach(groupedWorkouts.prefix(10), id: \.0) { dateKey, workouts in
                VStack(alignment: .leading, spacing: 12) {
                    Text(dateKey)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)

                    ForEach(workouts) { workout in
                        WorkoutRow(workout: workout)
                    }
                }
            }
        }
    }
}

// MARK: - Calendar Heatmap View

struct CalendarHeatmapView: View {
    let workouts: [Workout]

    private let calendar = Calendar.current
    private let columns = 7
    private let rows = 5

    private var last30Days: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<30).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed()
    }

    private var workoutsByDate: [Date: [Workout]] {
        Dictionary(grouping: workouts) { workout in
            calendar.startOfDay(for: workout.completedAt)
        }
    }

    private func intensity(for date: Date) -> Double {
        let count = workoutsByDate[date]?.count ?? 0
        switch count {
        case 0: return 0
        case 1: return 0.3
        case 2: return 0.5
        case 3: return 0.7
        default: return 1.0
        }
    }

    private func xpEarned(for date: Date) -> Int {
        workoutsByDate[date]?.reduce(0) { $0 + $1.xpEarned } ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LAST 30 DAYS")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .tracking(1)

            VStack(spacing: 4) {
                // Day labels
                HStack(spacing: 4) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Theme.textMuted)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    // Add empty cells for alignment
                    let firstDay = last30Days.first ?? Date()
                    let weekday = calendar.component(.weekday, from: firstDay)
                    let emptyDays = weekday - 1

                    ForEach(0..<emptyDays, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.clear)
                            .aspectRatio(1, contentMode: .fit)
                    }

                    ForEach(last30Days, id: \.self) { date in
                        CalendarDayCell(
                            date: date,
                            intensity: intensity(for: date),
                            xp: xpEarned(for: date)
                        )
                    }
                }
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(12)

            // Legend
            HStack(spacing: 8) {
                Text("Less")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textMuted)

                ForEach([0.0, 0.3, 0.5, 0.7, 1.0], id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(intensity == 0 ? Theme.elevated : Theme.primary.opacity(intensity))
                        .frame(width: 12, height: 12)
                }

                Text("More")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct CalendarDayCell: View {
    let date: Date
    let intensity: Double
    let xp: Int

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(intensity == 0 ? Theme.elevated : Theme.primary.opacity(intensity))

            if isToday {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Theme.secondary, lineWidth: 2)
            }

            Text(dayNumber)
                .font(.system(size: 10, weight: isToday ? .bold : .medium))
                .foregroundColor(intensity > 0.5 ? .white : Theme.textSecondary)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textPrimary)

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Theme.textMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Workout Row

struct WorkoutRow: View {
    let workout: Workout

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(workout.workoutType == .cardio ? Theme.secondary.opacity(0.2) : Theme.primary.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: workout.workoutType == .cardio ? "figure.run" : "dumbbell.fill")
                    .font(.system(size: 16))
                    .foregroundColor(workout.workoutType == .cardio ? Theme.secondary : Theme.primary)
            }

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textPrimary)

                Text(workout.detailsText)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted)
            }

            Spacer()

            // XP earned
            HStack(spacing: 4) {
                Text("+\(workout.xpEarned)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.success)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.warning)
            }
        }
        .padding(12)
        .background(Theme.cardBackground)
        .cornerRadius(10)
    }
}

#Preview {
    HistoryTab(player: {
        let p = Player(name: "Test")
        p.totalXP = 2450
        p.workouts = [
            Workout(name: "Running", workoutType: .cardio, xpEarned: 156, durationMinutes: 30),
            Workout(name: "Bench Press", workoutType: .strength, xpEarned: 142, weight: 135, reps: 10, sets: 3)
        ]
        return p
    }())
    .modelContainer(for: [Player.self, Workout.self], inMemory: true)
}
