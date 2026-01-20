import Foundation
import SwiftData

@Model
final class Pet {
    var id: UUID
    var name: String
    var speciesRaw: String
    var level: Int
    var happiness: Double  // 0-100
    var isAway: Bool
    var awayDate: Date?
    var lastHappinessUpdateDate: Date

    var player: Player?

    // Computed properties
    var species: PetSpecies {
        get { PetSpecies(rawValue: speciesRaw) ?? .dragon }
        set { speciesRaw = newValue.rawValue }
    }

    var mood: PetMood {
        PetMood.from(happiness: happiness)
    }

    var levelUpCost: Int {
        // Formula: 50 × level^1.5
        // Level 2 = 70, Level 3 = 130, Level 4 = 200, Level 5 = 280
        Int(50.0 * pow(Double(level + 1), 1.5))
    }

    var xpBonusMultiplier: Double {
        // This returns the multiplier for the pet's preferred workout type
        // For actual calculation, use species.xpMultiplier(for:petLevel:)
        return species.xpMultiplier(for: .strength, petLevel: level)
    }

    init(name: String, species: PetSpecies) {
        self.id = UUID()
        self.name = name
        self.speciesRaw = species.rawValue
        self.level = 1
        self.happiness = 100.0
        self.isAway = false
        self.awayDate = nil
        self.lastHappinessUpdateDate = Date()
    }
}
