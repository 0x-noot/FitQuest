import Foundation
import SwiftData

@Model
final class Pet {
    var id: UUID = UUID()
    var name: String = ""
    var speciesRaw: String = "dragon"
    var totalXP: Int = 0  // XP-based leveling (replaces Essence-based)
    var happiness: Double = 100.0  // 0-100
    var isAway: Bool = false
    var awayDate: Date?
    var lastHappinessUpdateDate: Date = Date()

    // Play interaction tracking
    var playSessionsToday: Int = 0
    var lastPlayDate: Date?
    var tapCount: Int = 0  // Tracks taps within a play session

    // Equipped accessories (stored as comma-separated IDs)
    var equippedAccessoriesRaw: String = ""

    var player: Player?

    // Computed properties
    var species: PetSpecies {
        get { PetSpecies(rawValue: speciesRaw) ?? .dragon }
        set { speciesRaw = newValue.rawValue }
    }

    var mood: PetMood {
        PetMood.from(happiness: happiness)
    }

    var evolutionStage: EvolutionStage {
        EvolutionStage.from(level: currentLevel)
    }

    var evolutionIconName: String {
        species.iconName(for: evolutionStage)
    }

    // Equipped accessories
    var equippedAccessories: [String] {
        get {
            guard !equippedAccessoriesRaw.isEmpty else { return [] }
            return equippedAccessoriesRaw.split(separator: ",").map { String($0) }
        }
        set {
            equippedAccessoriesRaw = newValue.joined(separator: ",")
        }
    }

    var equippedHat: Accessory? {
        equippedAccessories.compactMap { Accessory.accessory(withId: $0) }.first { $0.category == .hat }
    }

    var equippedBackground: Accessory? {
        equippedAccessories.compactMap { Accessory.accessory(withId: $0) }.first { $0.category == .background }
    }

    var equippedEffect: Accessory? {
        equippedAccessories.compactMap { Accessory.accessory(withId: $0) }.first { $0.category == .effect }
    }

    func equipAccessory(_ accessory: Accessory) {
        // Remove any existing accessory in the same category
        var accessories = equippedAccessories.filter { id in
            guard let existing = Accessory.accessory(withId: id) else { return true }
            return existing.category != accessory.category
        }
        accessories.append(accessory.id)
        equippedAccessories = accessories
    }

    func unequipAccessory(_ accessory: Accessory) {
        equippedAccessories = equippedAccessories.filter { $0 != accessory.id }
    }

    // XP-based leveling (same formula as player used to have)
    var currentLevel: Int {
        LevelManager.levelFor(xp: totalXP)
    }

    var xpForCurrentLevel: Int {
        LevelManager.xpRangeFor(level: currentLevel).start
    }

    var xpForNextLevel: Int {
        LevelManager.xpRangeFor(level: currentLevel).end
    }

    var xpProgress: Double {
        LevelManager.progressFor(xp: totalXP)
    }

    var xpToNextLevel: Int {
        LevelManager.xpToNextLevel(currentXP: totalXP)
    }

    var xpBonusMultiplier: Double {
        // This returns the multiplier for the pet's preferred workout type
        // For actual calculation, use species.xpMultiplier(for:petLevel:)
        return species.xpMultiplier(for: .strength, petLevel: currentLevel)
    }

    // Play session constants
    static let maxPlaySessionsPerDay = 3
    static let tapsPerSession = 3
    static let happinessPerSession = 2.0

    // Computed property for remaining play sessions
    var remainingPlaySessions: Int {
        resetPlaySessionsIfNeeded()
        return max(0, Pet.maxPlaySessionsPerDay - playSessionsToday)
    }

    var canPlay: Bool {
        !isAway && remainingPlaySessions > 0
    }

    private func resetPlaySessionsIfNeeded() {
        guard let lastPlay = lastPlayDate else { return }
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastPlay) {
            // This will be called from PetManager to avoid mutating in getter
        }
    }

    init(name: String, species: PetSpecies) {
        self.id = UUID()
        self.name = name
        self.speciesRaw = species.rawValue
        self.totalXP = 0
        self.happiness = 100.0
        self.isAway = false
        self.awayDate = nil
        self.lastHappinessUpdateDate = Date()
        self.playSessionsToday = 0
        self.lastPlayDate = nil
        self.tapCount = 0
        self.equippedAccessoriesRaw = ""
    }

    /// Add XP and return if leveled up
    @discardableResult
    func addXP(_ amount: Int) -> Bool {
        let previousLevel = currentLevel
        totalXP += amount
        return currentLevel > previousLevel
    }
}
