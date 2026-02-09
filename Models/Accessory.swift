import Foundation
import SwiftUI

enum AccessoryCategory: String, Codable, CaseIterable {
    case hat
    case background
    case effect

    var displayName: String {
        switch self {
        case .hat: return "Hats"
        case .background: return "Backgrounds"
        case .effect: return "Effects"
        }
    }

    var iconName: String {
        switch self {
        case .hat: return "crown.fill"
        case .background: return "circle.hexagongrid.fill"
        case .effect: return "sparkles"
        }
    }
}

enum AccessoryRarity: String, Codable, CaseIterable {
    case common
    case rare
    case legendary

    var displayName: String {
        switch self {
        case .common: return "Common"
        case .rare: return "Rare"
        case .legendary: return "Legendary"
        }
    }

    var color: Color {
        switch self {
        case .common: return Theme.textSecondary
        case .rare: return Theme.primary
        case .legendary: return Theme.warning
        }
    }

    var priceMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .rare: return 2.5
        case .legendary: return 5.0
        }
    }
}

struct Accessory: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let category: AccessoryCategory
    let rarity: AccessoryRarity
    let baseCost: Int
    let iconName: String  // SF Symbol for hats, or gradient name for backgrounds
    let description: String

    var cost: Int {
        Int(Double(baseCost) * rarity.priceMultiplier)
    }

    // All available accessories
    static let all: [Accessory] = [
        // Hats - Common
        Accessory(id: "hat_crown", name: "Crown", category: .hat, rarity: .common, baseCost: 50, iconName: "crown.fill", description: "A simple golden crown"),
        Accessory(id: "hat_party", name: "Party Hat", category: .hat, rarity: .common, baseCost: 50, iconName: "party.popper.fill", description: "Time to celebrate!"),
        Accessory(id: "hat_star", name: "Star Cap", category: .hat, rarity: .common, baseCost: 50, iconName: "star.fill", description: "Shine bright like a star"),

        // Hats - Rare
        Accessory(id: "hat_wizard", name: "Wizard Hat", category: .hat, rarity: .rare, baseCost: 75, iconName: "wand.and.stars", description: "Mystical powers await"),
        Accessory(id: "hat_headband", name: "Fitness Headband", category: .hat, rarity: .rare, baseCost: 75, iconName: "figure.run", description: "Ready to sweat!"),

        // Hats - Legendary
        Accessory(id: "hat_halo", name: "Golden Halo", category: .hat, rarity: .legendary, baseCost: 100, iconName: "sun.max.fill", description: "Divine presence"),

        // Backgrounds - Common
        Accessory(id: "bg_gradient_blue", name: "Ocean Wave", category: .background, rarity: .common, baseCost: 40, iconName: "blue", description: "Calming blue gradient"),
        Accessory(id: "bg_gradient_green", name: "Forest", category: .background, rarity: .common, baseCost: 40, iconName: "green", description: "Natural green tones"),
        Accessory(id: "bg_gradient_purple", name: "Twilight", category: .background, rarity: .common, baseCost: 40, iconName: "purple", description: "Mystical purple hues"),

        // Backgrounds - Rare
        Accessory(id: "bg_gradient_fire", name: "Inferno", category: .background, rarity: .rare, baseCost: 60, iconName: "fire", description: "Blazing hot gradient"),
        Accessory(id: "bg_gradient_rainbow", name: "Rainbow", category: .background, rarity: .rare, baseCost: 60, iconName: "rainbow", description: "Full spectrum beauty"),

        // Backgrounds - Legendary
        Accessory(id: "bg_gradient_gold", name: "Golden Hour", category: .background, rarity: .legendary, baseCost: 80, iconName: "gold", description: "Luxurious golden glow"),

        // Effects - Common
        Accessory(id: "effect_hearts", name: "Floating Hearts", category: .effect, rarity: .common, baseCost: 60, iconName: "heart.fill", description: "Love is in the air"),
        Accessory(id: "effect_stars", name: "Twinkling Stars", category: .effect, rarity: .common, baseCost: 60, iconName: "star.fill", description: "Starry atmosphere"),

        // Effects - Rare
        Accessory(id: "effect_fire", name: "Fire Aura", category: .effect, rarity: .rare, baseCost: 80, iconName: "flame.fill", description: "Burning with passion"),
        Accessory(id: "effect_sparkle", name: "Magic Sparkles", category: .effect, rarity: .rare, baseCost: 80, iconName: "sparkles", description: "Enchanted presence"),

        // Effects - Legendary
        Accessory(id: "effect_lightning", name: "Thunder Aura", category: .effect, rarity: .legendary, baseCost: 100, iconName: "bolt.fill", description: "Electrifying power"),
    ]

    static func accessory(withId id: String) -> Accessory? {
        all.first { $0.id == id }
    }

    static func accessories(for category: AccessoryCategory) -> [Accessory] {
        all.filter { $0.category == category }
    }
}

// Background gradient colors
extension Accessory {
    var backgroundGradient: LinearGradient? {
        guard category == .background else { return nil }

        switch iconName {
        case "blue":
            return LinearGradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "green":
            return LinearGradient(colors: [.green.opacity(0.3), .mint.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "purple":
            return LinearGradient(colors: [.purple.opacity(0.3), .indigo.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "fire":
            return LinearGradient(colors: [.red.opacity(0.3), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "rainbow":
            return LinearGradient(colors: [.red.opacity(0.2), .orange.opacity(0.2), .yellow.opacity(0.2), .green.opacity(0.2), .blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "gold":
            return LinearGradient(colors: [.yellow.opacity(0.4), .orange.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return nil
        }
    }

    /// Darker, muted gradient for the rectangular habitat box in PixelPetDisplay
    var habitatGradient: LinearGradient? {
        guard category == .background else { return nil }

        switch id {
        case "bg_gradient_blue":
            return LinearGradient(
                colors: [Color(hex: "1A2A4A"), Color(hex: "2A4A5A")],
                startPoint: .top, endPoint: .bottom
            )
        case "bg_gradient_green":
            return LinearGradient(
                colors: [Color(hex: "1A3A2A"), Color(hex: "2A4A2A")],
                startPoint: .top, endPoint: .bottom
            )
        case "bg_gradient_purple":
            return LinearGradient(
                colors: [Color(hex: "1A1A3A"), Color(hex: "3A2A4A")],
                startPoint: .top, endPoint: .bottom
            )
        case "bg_gradient_fire":
            return LinearGradient(
                colors: [Color(hex: "3A1A1A"), Color(hex: "4A2A1A")],
                startPoint: .top, endPoint: .bottom
            )
        case "bg_gradient_rainbow":
            return LinearGradient(
                colors: [
                    Color.red.opacity(0.15),
                    Color.orange.opacity(0.15),
                    Color.yellow.opacity(0.15),
                    Color.green.opacity(0.15),
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.15)
                ],
                startPoint: .top, endPoint: .bottom
            )
        case "bg_gradient_gold":
            return LinearGradient(
                colors: [Color(hex: "3A2A10"), Color(hex: "4A3A1A")],
                startPoint: .top, endPoint: .bottom
            )
        default:
            return nil
        }
    }

    /// Themed floor dot color for the habitat box
    var habitatFloorColor: Color? {
        guard category == .background else { return nil }

        switch id {
        case "bg_gradient_blue": return Color.cyan.opacity(0.4)
        case "bg_gradient_green": return Color.green.opacity(0.4)
        case "bg_gradient_purple": return Color.purple.opacity(0.4)
        case "bg_gradient_fire": return Color.orange.opacity(0.4)
        case "bg_gradient_rainbow": return PixelTheme.gbLight.opacity(0.3)
        case "bg_gradient_gold": return Color(hex: "FFD700").opacity(0.4)
        default: return nil
        }
    }
}
