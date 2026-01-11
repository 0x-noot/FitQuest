import Foundation

struct LevelManager {

    /// XP required to reach a given level
    /// Formula: XP = 100 * level^1.8
    static func xpRequiredFor(level: Int) -> Int {
        guard level > 1 else { return 0 }
        return Int(100 * pow(Double(level), 1.8))
    }

    /// Determine level from total XP
    static func levelFor(xp: Int) -> Int {
        var level = 1
        while xpRequiredFor(level: level + 1) <= xp {
            level += 1
        }
        return level
    }

    /// Get XP range for current level (min to next level threshold)
    static func xpRangeFor(level: Int) -> (start: Int, end: Int) {
        let lower = xpRequiredFor(level: level)
        let upper = xpRequiredFor(level: level + 1)
        return (lower, upper)
    }

    /// Calculate progress percentage within current level
    static func progressFor(xp: Int) -> Double {
        let level = levelFor(xp: xp)
        let range = xpRangeFor(level: level)
        let current = xp - range.start
        let needed = range.end - range.start
        guard needed > 0 else { return 0 }
        return Double(current) / Double(needed)
    }

    /// XP needed to reach next level
    static func xpToNextLevel(currentXP: Int) -> Int {
        let level = levelFor(xp: currentXP)
        let nextLevelXP = xpRequiredFor(level: level + 1)
        return nextLevelXP - currentXP
    }

    /// Milestone levels that unlock special rewards
    static let milestoneLevels: Set<Int> = [5, 10, 15, 20, 25, 30, 40, 50, 75, 100]

    /// Check if a level is a milestone
    static func isMilestone(level: Int) -> Bool {
        milestoneLevels.contains(level)
    }
}
