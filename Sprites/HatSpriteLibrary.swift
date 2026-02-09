import SwiftUI

// MARK: - Hat Sprite Library

/// Pixel art sprites for equippable hat accessories
struct HatSpriteLibrary {

    /// Get the pixel sprite for a hat accessory
    static func sprite(for accessoryId: String) -> PixelSprite? {
        switch accessoryId {
        case "hat_crown": return crownSprite
        case "hat_party": return partyHatSprite
        case "hat_star": return starCapSprite
        case "hat_wizard": return wizardHatSprite
        case "hat_headband": return headbandSprite
        case "hat_halo": return haloSprite
        default: return nil
        }
    }

    /// Get the color palette for a hat accessory
    static func palette(for accessoryId: String) -> PixelTheme.PetPalette? {
        switch accessoryId {
        case "hat_crown": return crownPalette
        case "hat_party": return partyHatPalette
        case "hat_star": return starCapPalette
        case "hat_wizard": return wizardHatPalette
        case "hat_headband": return headbandPalette
        case "hat_halo": return haloPalette
        default: return nil
        }
    }

    /// Vertical offset in pixel units (how many pixels above pet center)
    /// Negative = above center, accounts for hat sitting on pet's head
    static func verticalOffset(for accessoryId: String) -> CGFloat {
        switch accessoryId {
        case "hat_crown": return -13
        case "hat_party": return -14
        case "hat_star": return -12
        case "hat_wizard": return -15
        case "hat_headband": return -12
        case "hat_halo": return -16
        default: return -13
        }
    }

    // MARK: - Crown (12x6) — 3-pointed golden crown

    static let crownPalette = PixelTheme.PetPalette(
        highlight: Color(hex: "FFF4CC"),
        fill: Color(hex: "FFD700"),
        shadow: Color(hex: "FFAA00"),
        outline: Color(hex: "CC8800")
    )

    static let crownSprite = PixelSprite(width: 12, height: 6, data: [
        [0,4,0,0,4,0,0,4,0,0,4,0],
        [0,4,2,0,4,2,2,4,0,2,4,0],
        [0,4,2,2,2,2,2,2,2,2,4,0],
        [4,2,1,2,2,1,1,2,2,1,2,4],
        [4,2,2,2,2,2,2,2,2,2,2,4],
        [4,4,4,4,4,4,4,4,4,4,4,4],
    ])

    // MARK: - Party Hat (10x8) — Striped cone

    static let partyHatPalette = PixelTheme.PetPalette(
        highlight: Color(hex: "FFB6E0"),
        fill: Color(hex: "FF69B4"),
        shadow: Color(hex: "9B59B6"),
        outline: Color(hex: "6B3A7D")
    )

    static let partyHatSprite = PixelSprite(width: 10, height: 8, data: [
        [0,0,0,0,4,4,0,0,0,0],
        [0,0,0,0,4,1,0,0,0,0],
        [0,0,0,4,3,2,4,0,0,0],
        [0,0,0,4,2,3,4,0,0,0],
        [0,0,4,3,2,2,3,4,0,0],
        [0,0,4,2,3,3,2,4,0,0],
        [0,4,3,2,2,2,2,3,4,0],
        [4,4,4,4,4,4,4,4,4,4],
    ])

    // MARK: - Star Cap (12x6) — Baseball cap with star

    static let starCapPalette = PixelTheme.PetPalette(
        highlight: Color(hex: "FFFFFF"),
        fill: Color(hex: "4488FF"),
        shadow: Color(hex: "3366CC"),
        outline: Color(hex: "224488")
    )

    static let starCapSprite = PixelSprite(width: 12, height: 6, data: [
        [0,0,0,4,4,4,4,4,0,0,0,0],
        [0,0,4,2,2,2,2,2,4,0,0,0],
        [0,4,2,2,1,2,2,2,2,4,0,0],
        [0,4,2,1,1,1,2,2,2,4,0,0],
        [4,2,2,2,1,2,2,2,2,2,4,0],
        [4,4,4,4,4,4,4,4,4,4,4,4],
    ])

    // MARK: - Wizard Hat (10x10) — Tall pointed cone with stars

    static let wizardHatPalette = PixelTheme.PetPalette(
        highlight: Color(hex: "D8B4FE"),
        fill: Color(hex: "9B59B6"),
        shadow: Color(hex: "7D3C98"),
        outline: Color(hex: "512E5F")
    )

    static let wizardHatSprite = PixelSprite(width: 10, height: 10, data: [
        [0,0,0,0,4,4,0,0,0,0],
        [0,0,0,4,2,2,4,0,0,0],
        [0,0,0,4,2,1,4,0,0,0],
        [0,0,4,2,2,2,2,4,0,0],
        [0,0,4,2,2,2,1,4,0,0],
        [0,4,3,2,1,2,2,3,4,0],
        [0,4,3,2,2,2,2,3,4,0],
        [4,3,2,2,2,1,2,2,3,4],
        [4,3,2,2,2,2,2,2,3,4],
        [4,4,4,4,4,4,4,4,4,4],
    ])

    // MARK: - Fitness Headband (14x3) — Red band with white stripe

    static let headbandPalette = PixelTheme.PetPalette(
        highlight: Color(hex: "FFFFFF"),
        fill: Color(hex: "FF4444"),
        shadow: Color(hex: "CC2222"),
        outline: Color(hex: "991111")
    )

    static let headbandSprite = PixelSprite(width: 14, height: 3, data: [
        [4,4,4,4,4,4,4,4,4,4,4,4,4,4],
        [4,2,2,1,2,2,1,1,2,2,1,2,2,4],
        [4,4,4,4,4,4,4,4,4,4,4,4,4,4],
    ])

    // MARK: - Golden Halo (14x4) — Floating gold ring

    static let haloPalette = PixelTheme.PetPalette(
        highlight: Color(hex: "FFFFFF"),
        fill: Color(hex: "FFD700"),
        shadow: Color(hex: "FFAA00"),
        outline: Color(hex: "CC8800")
    )

    static let haloSprite = PixelSprite(width: 14, height: 4, data: [
        [0,0,0,4,4,4,4,4,4,4,4,0,0,0],
        [0,0,4,1,2,2,1,1,2,2,1,4,0,0],
        [0,0,4,3,2,2,2,2,2,2,3,4,0,0],
        [0,0,0,4,4,4,4,4,4,4,4,0,0,0],
    ])
}
