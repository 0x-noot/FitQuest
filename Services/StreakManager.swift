import Foundation

struct StreakManager {

    /// Check if two dates are on the same calendar day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }

    /// Check if a date is yesterday relative to another date
    static func isYesterday(_ date: Date, relativeTo referenceDate: Date) -> Bool {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: referenceDate) else {
            return false
        }
        return isSameDay(date, yesterday)
    }

    /// Check if this is the first workout of the day
    static func isFirstWorkoutOfDay(lastWorkoutDate: Date?) -> Bool {
        guard let lastDate = lastWorkoutDate else { return true }
        return !isSameDay(lastDate, Date())
    }

    /// Calculate updated streak based on last workout date
    static func calculateStreak(
        currentStreak: Int,
        lastWorkoutDate: Date?,
        now: Date = Date()
    ) -> Int {
        guard let lastDate = lastWorkoutDate else {
            // First workout ever
            return 1
        }

        if isSameDay(lastDate, now) {
            // Already worked out today, streak unchanged
            return currentStreak
        } else if isYesterday(lastDate, relativeTo: now) {
            // Worked out yesterday, increment streak
            return currentStreak + 1
        } else {
            // Streak broken, start new streak
            return 1
        }
    }

    /// Check if streak would be broken if no workout today
    static func isStreakAtRisk(lastWorkoutDate: Date?) -> Bool {
        guard let lastDate = lastWorkoutDate else { return false }
        return !isSameDay(lastDate, Date())
    }

    /// Get the start of today (midnight)
    static func startOfToday() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

    /// Format streak for display
    static func formatStreak(_ streak: Int) -> String {
        if streak == 1 {
            return "1 day"
        } else {
            return "\(streak) days"
        }
    }

    // MARK: - Weekly Streak Helpers

    /// Get the start of the current week
    static func startOfCurrentWeek() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
    }

    /// Check if two dates are in the same week
    static func isSameWeek(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, equalTo: date2, toGranularity: .weekOfYear)
    }

    /// Check if a date is in the previous week relative to another date
    static func isPreviousWeek(_ date: Date, relativeTo referenceDate: Date) -> Bool {
        let calendar = Calendar.current
        guard let previousWeekDate = calendar.date(byAdding: .weekOfYear, value: -1, to: referenceDate) else {
            return false
        }
        return isSameWeek(date, previousWeekDate)
    }

    /// Format weekly streak for display
    static func formatWeeklyStreak(_ streak: Int) -> String {
        if streak == 1 {
            return "1 week"
        } else {
            return "\(streak) weeks"
        }
    }

    /// Get encouraging text based on weekly progress
    static func weeklyProgressText(completed: Int, goal: Int) -> String {
        if completed == 0 {
            return "Start your week strong!"
        } else if completed < goal {
            let remaining = goal - completed
            if remaining == 1 {
                return "Just 1 more day to hit your goal!"
            } else {
                return "\(remaining) more days to hit your goal"
            }
        } else {
            return "Weekly goal achieved!"
        }
    }
}
