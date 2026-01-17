import SwiftUI

enum PlayerRank: String, CaseIterable, Identifiable {
    case bronze
    case silver
    case gold
    case platinum
    case diamond

    var id: String { rawValue }

    /// Determine rank based on player level
    static func rank(for level: Int) -> PlayerRank {
        switch level {
        case 1...10: return .bronze
        case 11...25: return .silver
        case 26...50: return .gold
        case 51...100: return .platinum
        default: return .diamond
        }
    }

    /// Display name for the rank
    var displayName: String {
        rawValue.capitalized
    }

    /// Minimum level required for this rank
    var minLevel: Int {
        switch self {
        case .bronze: return 1
        case .silver: return 11
        case .gold: return 26
        case .platinum: return 51
        case .diamond: return 101
        }
    }

    /// Color associated with the rank
    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.80, green: 0.50, blue: 0.20)   // #CD7F32
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)   // #C0C0C0
        case .gold: return Color(red: 1.00, green: 0.84, blue: 0.00)     // #FFD700
        case .platinum: return Color(red: 0.90, green: 0.89, blue: 0.89) // #E5E4E2
        case .diamond: return Color(red: 0.13, green: 0.83, blue: 0.93)  // #22D3EE (cyan)
        }
    }

    /// Secondary color for gradients
    var secondaryColor: Color {
        switch self {
        case .bronze: return Color(red: 0.55, green: 0.35, blue: 0.15)
        case .silver: return Color(red: 0.55, green: 0.55, blue: 0.60)
        case .gold: return Color(red: 0.85, green: 0.65, blue: 0.00)
        case .platinum: return Color(red: 0.70, green: 0.70, blue: 0.75)
        case .diamond: return Color(red: 0.40, green: 0.50, blue: 0.90)
        }
    }

    /// Gradient for the rank badge
    var gradient: LinearGradient {
        LinearGradient(
            colors: [color, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// SF Symbol icon for the rank
    var iconName: String {
        switch self {
        case .bronze: return "shield.fill"
        case .silver: return "shield.fill"
        case .gold: return "shield.fill"
        case .platinum: return "crown.fill"
        case .diamond: return "diamond.fill"
        }
    }

    /// Next rank after this one (nil if diamond)
    var nextRank: PlayerRank? {
        switch self {
        case .bronze: return .silver
        case .silver: return .gold
        case .gold: return .platinum
        case .platinum: return .diamond
        case .diamond: return nil
        }
    }

    /// Level range description
    var levelRange: String {
        switch self {
        case .bronze: return "Levels 1-10"
        case .silver: return "Levels 11-25"
        case .gold: return "Levels 26-50"
        case .platinum: return "Levels 51-100"
        case .diamond: return "Level 100+"
        }
    }
}
