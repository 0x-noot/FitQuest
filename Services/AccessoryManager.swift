import Foundation

class AccessoryManager {
    static let shared = AccessoryManager()

    private init() {}

    // MARK: - Purchase

    func canPurchase(accessory: Accessory, player: Player) -> Bool {
        guard !player.hasUnlocked(accessory) else { return false }
        return player.essenceCurrency >= accessory.cost
    }

    func purchase(accessory: Accessory, player: Player) -> Bool {
        guard canPurchase(accessory: accessory, player: player) else { return false }

        player.essenceCurrency -= accessory.cost
        player.unlockAccessory(accessory)

        return true
    }

    // MARK: - Equip

    func equip(accessory: Accessory, pet: Pet, player: Player) -> Bool {
        guard player.hasUnlocked(accessory) else { return false }
        pet.equipAccessory(accessory)
        return true
    }

    func unequip(accessory: Accessory, pet: Pet) {
        pet.unequipAccessory(accessory)
    }

    // MARK: - Helpers

    func unlockedAccessories(for player: Player) -> [Accessory] {
        player.unlockedAccessories.compactMap { Accessory.accessory(withId: $0) }
    }

    func unlockedAccessories(for player: Player, category: AccessoryCategory) -> [Accessory] {
        unlockedAccessories(for: player).filter { $0.category == category }
    }

    func lockedAccessories(for player: Player) -> [Accessory] {
        Accessory.all.filter { !player.hasUnlocked($0) }
    }

    func lockedAccessories(for player: Player, category: AccessoryCategory) -> [Accessory] {
        lockedAccessories(for: player).filter { $0.category == category }
    }
}
