import Foundation

enum PetSpecies: String, Codable, CaseIterable {
    case plant
    case cat
    case dog
    case wolf // Kept for backward compatibility (existing data)
    case dragon

    /// Species available for selection in onboarding (excludes deprecated wolf)
    static var selectableSpecies: [PetSpecies] {
        [.plant, .cat, .dog, .dragon]
    }

    var displayName: String {
        switch self {
        case .plant: return "Sprout"
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .wolf: return "Wolf"
        case .dragon: return "Dragon"
        }
    }

    var iconName: String {
        switch self {
        case .plant: return "leaf.fill"
        case .cat: return "cat.fill"
        case .dog: return "dog.fill"
        case .wolf: return "pawprint.fill"
        case .dragon: return "flame"
        }
    }

    var description: String {
        switch self {
        case .plant: return "Grows stronger with consistency. +3% all XP (scales with level!)"
        case .cat: return "Quick and agile. +5% cardio XP (scales with level!)"
        case .dog: return "Loyal workout buddy. +3% all XP (scales with level!)"
        case .wolf: return "Fierce and powerful. +5% strength XP (scales with level!)"
        case .dragon: return "Legendary power. +7% strength XP (scales with level!)"
        }
    }

    var personality: String {
        switch self {
        case .plant: return "Patient & Steady"
        case .cat: return "Quick & Playful"
        case .dog: return "Loyal & Energetic"
        case .wolf: return "Fierce & Determined"
        case .dragon: return "Legendary & Powerful"
        }
    }

    // Calculate XP multiplier based on workout type and pet level
    func xpMultiplier(for workoutType: WorkoutType, petLevel: Int) -> Double {
        let levelBonus = Double(petLevel - 1)  // 0 for level 1, 1 for level 2, etc.

        switch self {
        case .plant:
            // Plant: +3% all XP (balanced, grows with consistency)
            // Scales +0.3% per level
            return 1.03 + (levelBonus * 0.003)

        case .cat:
            // Cat: +5% cardio, 0% strength
            // Scales +0.5% per level
            if workoutType == .cardio {
                return 1.05 + (levelBonus * 0.005)
            } else {
                return 1.0
            }

        case .dog:
            // Dog: +3% all XP (loyal buddy, balanced)
            // Scales +0.3% per level
            return 1.03 + (levelBonus * 0.003)

        case .wolf:
            // Wolf: +5% strength, 0% cardio
            // Scales +0.5% per level
            if workoutType == .strength {
                return 1.05 + (levelBonus * 0.005)
            } else {
                return 1.0
            }

        case .dragon:
            // Dragon: +7% strength (highest specialist bonus)
            // Scales +0.7% per level
            if workoutType == .strength {
                return 1.07 + (levelBonus * 0.007)
            } else {
                return 1.0
            }
        }
    }

    // Get the base bonus percentage for display
    var baseBonus: String {
        switch self {
        case .plant: return "3%"
        case .cat: return "5%"
        case .dog: return "3%"
        case .wolf: return "5%"
        case .dragon: return "7%"
        }
    }

    // Get the bonus type description
    var bonusType: String {
        switch self {
        case .plant: return "Balanced"
        case .cat: return "Cardio"
        case .dog: return "Balanced"
        case .wolf: return "Strength"
        case .dragon: return "Strength"
        }
    }
}
