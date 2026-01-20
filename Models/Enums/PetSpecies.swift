import Foundation

enum PetSpecies: String, Codable, CaseIterable {
    case dragon
    case fox
    case turtle

    var displayName: String {
        switch self {
        case .dragon: return "Dragon"
        case .fox: return "Fox"
        case .turtle: return "Turtle"
        }
    }

    var iconName: String {
        switch self {
        case .dragon: return "flame"
        case .fox: return "hare.fill"
        case .turtle: return "tortoise.fill"
        }
    }

    var description: String {
        switch self {
        case .dragon: return "+5% strength XP (scales with level!)"
        case .fox: return "+5% cardio XP (scales with level!)"
        case .turtle: return "+2.5% balanced XP (scales with level!)"
        }
    }

    // Calculate XP multiplier based on workout type and pet level
    func xpMultiplier(for workoutType: WorkoutType, petLevel: Int) -> Double {
        let levelBonus = Double(petLevel - 1)  // 0 for level 1, 1 for level 2, etc.

        switch self {
        case .dragon:
            // Dragon: +5% strength, 0% cardio
            // Scales +0.5% per level
            if workoutType == .strength {
                return 1.05 + (levelBonus * 0.005)
            } else {
                return 1.0
            }

        case .fox:
            // Fox: +5% cardio, 0% strength
            // Scales +0.5% per level
            if workoutType == .cardio {
                return 1.05 + (levelBonus * 0.005)
            } else {
                return 1.0
            }

        case .turtle:
            // Turtle: +2.5% both (balanced)
            // Scales +0.25% per level (slower for balanced)
            return 1.025 + (levelBonus * 0.0025)
        }
    }

    // Get the base bonus percentage for display
    var baseBonus: String {
        switch self {
        case .dragon: return "5%"
        case .fox: return "5%"
        case .turtle: return "2.5%"
        }
    }

    // Get the bonus type description
    var bonusType: String {
        switch self {
        case .dragon: return "Strength"
        case .fox: return "Cardio"
        case .turtle: return "Balanced"
        }
    }
}
