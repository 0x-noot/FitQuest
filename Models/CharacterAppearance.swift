import SwiftData
import SwiftUI
import Foundation

@Model
final class CharacterAppearance {
    var id: UUID

    // Base appearance
    var bodyType: Int      // 0-2: slim, medium, muscular
    var skinTone: Int      // 0-5: color palette index
    var hairStyle: Int     // 0-9: hairstyle index
    var hairColor: Int     // 0-7: color palette index
    var eyeStyle: Int      // 0-5: eye design index

    // Outfit pieces
    var headwear: Int?     // nil = none
    var top: Int           // 0 = basic
    var bottom: Int
    var footwear: Int
    var accessory: Int?    // nil = none

    // Unlocked items
    var unlockedItems: String

    var player: Player?

    init() {
        self.id = UUID()
        self.bodyType = 1
        self.skinTone = 2
        self.hairStyle = 0
        self.hairColor = 0
        self.eyeStyle = 0
        self.headwear = nil
        self.top = 0
        self.bottom = 0
        self.footwear = 0
        self.accessory = nil
        self.unlockedItems = ""
    }

    func hasUnlocked(_ category: String, index: Int) -> Bool {
        unlockedItems.contains("\(category):\(index)")
    }

    func unlock(_ category: String, index: Int) {
        guard !hasUnlocked(category, index: index) else { return }
        if unlockedItems.isEmpty {
            unlockedItems = "\(category):\(index)"
        } else {
            unlockedItems += ",\(category):\(index)"
        }
    }

    // Color palettes for placeholder rendering
    static let skinTones: [Color] = [
        Color(red: 1.0, green: 0.87, blue: 0.77),   // Light
        Color(red: 0.96, green: 0.80, blue: 0.69),  // Fair
        Color(red: 0.87, green: 0.67, blue: 0.51),  // Medium
        Color(red: 0.76, green: 0.53, blue: 0.39),  // Tan
        Color(red: 0.55, green: 0.38, blue: 0.28),  // Brown
        Color(red: 0.36, green: 0.25, blue: 0.20)   // Dark
    ]

    static let hairColors: [Color] = [
        Color(red: 0.1, green: 0.1, blue: 0.1),     // Black
        Color(red: 0.35, green: 0.22, blue: 0.14),  // Brown
        Color(red: 0.85, green: 0.65, blue: 0.35),  // Blonde
        Color(red: 0.70, green: 0.25, blue: 0.15),  // Red
        Color(red: 0.5, green: 0.5, blue: 0.5),     // Gray
        Color(red: 0.95, green: 0.95, blue: 0.95),  // White
        Color(red: 0.55, green: 0.30, blue: 0.75),  // Purple (unlockable)
        Color(red: 0.25, green: 0.65, blue: 0.85)   // Blue (unlockable)
    ]

    static let outfitColors: [Color] = [
        Color(red: 0.2, green: 0.2, blue: 0.25),    // Dark gray
        Color(red: 0.55, green: 0.36, blue: 0.96),  // Purple
        Color(red: 0.13, green: 0.83, blue: 0.93),  // Cyan
        Color(red: 0.13, green: 0.77, blue: 0.37),  // Green
        Color(red: 0.97, green: 0.62, blue: 0.04)   // Orange
    ]

    var skinColor: Color {
        Self.skinTones[min(skinTone, Self.skinTones.count - 1)]
    }

    var currentHairColor: Color {
        Self.hairColors[min(hairColor, Self.hairColors.count - 1)]
    }

    var topColor: Color {
        Self.outfitColors[min(top, Self.outfitColors.count - 1)]
    }

    var bottomColor: Color {
        Self.outfitColors[min(bottom, Self.outfitColors.count - 1)]
    }
}

// Unlock requirements
struct CharacterUnlockRequirements {
    enum Requirement {
        case level(Int)
        case streak(Int)
        case workouts(Int)
    }

    static let requirements: [String: Requirement] = [
        "hairStyle:5": .level(10),
        "hairStyle:6": .level(15),
        "hairColor:6": .level(20),  // Purple hair
        "hairColor:7": .level(25),  // Blue hair
        "headwear:1": .level(5),
        "headwear:2": .level(10),
        "headwear:3": .level(20),
        "top:3": .streak(7),
        "accessory:1": .level(15),
        "accessory:2": .workouts(50)
    ]

    static func isUnlocked(_ key: String, level: Int, streak: Int, workoutCount: Int) -> Bool {
        guard let requirement = requirements[key] else { return true }

        switch requirement {
        case .level(let requiredLevel):
            return level >= requiredLevel
        case .streak(let requiredStreak):
            return streak >= requiredStreak
        case .workouts(let requiredCount):
            return workoutCount >= requiredCount
        }
    }

    static func requirementText(_ key: String) -> String? {
        guard let requirement = requirements[key] else { return nil }

        switch requirement {
        case .level(let level):
            return "Reach Level \(level)"
        case .streak(let days):
            return "\(days)-day streak"
        case .workouts(let count):
            return "\(count) total workouts"
        }
    }
}
