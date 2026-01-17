import SwiftUI

enum CharacterBackground: String, Codable, CaseIterable, Identifiable {
    case defaultDark
    case gym
    case outdoor
    case premium

    var id: String { rawValue }

    /// Display name for the background
    var displayName: String {
        switch self {
        case .defaultDark: return "Default"
        case .gym: return "Gym"
        case .outdoor: return "Outdoor"
        case .premium: return "Premium"
        }
    }

    /// Description of the background
    var description: String {
        switch self {
        case .defaultDark: return "Clean dark background"
        case .gym: return "Industrial gym vibes"
        case .outdoor: return "Nature and fresh air"
        case .premium: return "Abstract elegance"
        }
    }

    /// Minimum rank required to unlock this background
    var unlockRank: PlayerRank? {
        switch self {
        case .defaultDark: return nil  // Always available
        case .gym: return .silver
        case .outdoor: return .gold
        case .premium: return .platinum
        }
    }

    /// Check if this background is unlocked for a given rank
    func isUnlocked(for rank: PlayerRank) -> Bool {
        guard let requiredRank = unlockRank else { return true }

        let rankOrder: [PlayerRank] = [.bronze, .silver, .gold, .platinum, .diamond]
        guard let currentIndex = rankOrder.firstIndex(of: rank),
              let requiredIndex = rankOrder.firstIndex(of: requiredRank) else {
            return false
        }
        return currentIndex >= requiredIndex
    }

    /// Primary gradient colors for the background
    var gradientColors: [Color] {
        switch self {
        case .defaultDark:
            return [
                Color(red: 0.05, green: 0.05, blue: 0.06),
                Color(red: 0.08, green: 0.08, blue: 0.10)
            ]
        case .gym:
            return [
                Color(red: 0.12, green: 0.10, blue: 0.08),
                Color(red: 0.15, green: 0.12, blue: 0.10),
                Color(red: 0.10, green: 0.08, blue: 0.06)
            ]
        case .outdoor:
            return [
                Color(red: 0.05, green: 0.12, blue: 0.08),
                Color(red: 0.08, green: 0.15, blue: 0.12),
                Color(red: 0.06, green: 0.10, blue: 0.08)
            ]
        case .premium:
            return [
                Color(red: 0.10, green: 0.08, blue: 0.15),
                Color(red: 0.12, green: 0.10, blue: 0.18),
                Color(red: 0.08, green: 0.06, blue: 0.12)
            ]
        }
    }

    /// Create a gradient view for the background
    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Icon representing the background theme
    var iconName: String {
        switch self {
        case .defaultDark: return "moon.stars.fill"
        case .gym: return "dumbbell.fill"
        case .outdoor: return "leaf.fill"
        case .premium: return "sparkles"
        }
    }

    /// Accent color for the background theme
    var accentColor: Color {
        switch self {
        case .defaultDark: return Theme.primary
        case .gym: return Color(red: 0.80, green: 0.50, blue: 0.20) // Bronze/copper
        case .outdoor: return Color(red: 0.30, green: 0.70, blue: 0.40) // Green
        case .premium: return Color(red: 0.60, green: 0.40, blue: 0.80) // Purple
        }
    }
}
