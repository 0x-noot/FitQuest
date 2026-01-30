import SwiftUI

/// Purple/Violet dark mode palette
/// Used throughout the app for the pixel art Tamagotchi aesthetic
struct PixelTheme {

    // MARK: - Pet Color Palettes

    /// Species-specific 4-shade color palettes for vibrant, distinct pets
    struct PetPalette {
        let highlight: Color    // Lightest shade (shade 1) - highlights/shine
        let fill: Color         // Main body color (shade 2)
        let shadow: Color       // Shadow areas (shade 3)
        let outline: Color      // Outlines/darkest (shade 4)

        /// Get the vibrant color palette for a specific pet species
        /// Colors are bright and saturated to stand out against the dark purple background
        static func palette(for species: PetSpecies) -> PetPalette {
            switch species {
            case .plant:
                // Vibrant neon greens - high contrast against purple
                return PetPalette(
                    highlight: Color(hex: "AFFFAF"),  // Bright mint highlight
                    fill: Color(hex: "50FF50"),       // Vibrant neon green
                    shadow: Color(hex: "32CD32"),     // Lime green shadow
                    outline: Color(hex: "228B22")     // Forest green outline
                )
            case .cat:
                // Warm cream/ivory - cozy and complements purple
                return PetPalette(
                    highlight: Color(hex: "FFF8E7"),  // Light cream highlight
                    fill: Color(hex: "F5DEB3"),       // Wheat/warm ivory
                    shadow: Color(hex: "DEB887"),     // Burlywood shadow
                    outline: Color(hex: "A0826D")     // Warm brown outline
                )
            case .dog:
                // Bright golden yellow - high visibility
                return PetPalette(
                    highlight: Color(hex: "FFF4CC"),  // Light cream
                    fill: Color(hex: "FFD700"),       // Bright gold
                    shadow: Color(hex: "FFAA00"),     // Deep gold
                    outline: Color(hex: "CC8800")     // Bronze outline
                )
            case .wolf:
                // Cool cyan/teal - complementary to purple
                return PetPalette(
                    highlight: Color(hex: "E0FFFF"),  // Light cyan
                    fill: Color(hex: "88DDDD"),       // Soft teal
                    shadow: Color(hex: "5FAAAA"),     // Medium teal
                    outline: Color(hex: "3D7878")     // Deep teal outline
                )
            case .dragon:
                // Fiery bright red/coral - maximum contrast
                return PetPalette(
                    highlight: Color(hex: "FFAAAA"),  // Light coral
                    fill: Color(hex: "FF5555"),       // Bright red
                    shadow: Color(hex: "DD3333"),     // Deep red
                    outline: Color(hex: "AA2222")     // Dark crimson outline
                )
            }
        }

        /// Get color for a specific shade value (1-4)
        func color(for shade: Int) -> Color {
            switch shade {
            case 1: return highlight
            case 2: return fill
            case 3: return shadow
            case 4: return outline
            default: return .clear
            }
        }
    }
    // MARK: - Purple/Violet Dark 4-Shade Palette

    /// Deep purple-black - used for main background
    static let gbDarkest = Color(hex: "1A1625")

    /// Dark purple - used for card backgrounds, panels
    static let gbDark = Color(hex: "2D2640")

    /// Muted violet - used for borders, secondary elements
    static let gbLight = Color(hex: "6B5B95")

    /// Lavender white - used for text, highlights
    static let gbLightest = Color(hex: "E8E0F0")

    // MARK: - Semantic Colors (Dark Mode)

    /// Main app background (deep purple-black)
    static let background = gbDarkest

    /// Card and panel backgrounds (dark purple)
    static let cardBackground = gbDark

    /// Elevated surface (buttons, interactive elements)
    static let elevated = gbLight

    /// All borders and outlines (muted violet)
    static let border = gbLight

    /// Primary text color (lavender white)
    static let text = gbLightest

    /// Secondary/muted text (muted violet)
    static let textSecondary = gbLight

    /// Highlighted/selected state background
    static let highlight = gbLight

    /// Inverted text (on light backgrounds)
    static let textInverted = gbDarkest

    // MARK: - Pixel Border Thickness

    /// Standard border thickness in pixel units
    static let borderThickness: CGFloat = 2

    /// Thin border for smaller elements
    static let borderThin: CGFloat = 1
}

// MARK: - Pixel Scale Utilities

/// Utilities for pixel-perfect rendering
/// All sizes should be multiples of the base unit for crisp pixel art
struct PixelScale {
    /// Base pixel size - 4 points = 1 "pixel"
    static let unit: CGFloat = 4

    /// Convert pixel count to points
    /// - Parameter count: Number of pixels
    /// - Returns: Size in points
    static func px(_ count: Int) -> CGFloat {
        CGFloat(count) * unit
    }

    /// Convert pixel count to points (CGFloat version)
    static func px(_ count: CGFloat) -> CGFloat {
        count * unit
    }

    // MARK: - Common Sizes

    /// Small spacing (1 pixel = 4pt)
    static let spacingSmall = px(1)

    /// Medium spacing (2 pixels = 8pt)
    static let spacingMedium = px(2)

    /// Large spacing (3 pixels = 12pt)
    static let spacingLarge = px(3)

    /// Extra large spacing (4 pixels = 16pt)
    static let spacingXL = px(4)

    /// Standard corner radius for pixel borders
    static let cornerRadius = px(1)

    /// Icon sizes
    static let iconSmall = px(3)   // 12pt
    static let iconMedium = px(4)  // 16pt
    static let iconLarge = px(6)   // 24pt
}

// MARK: - Pixel Font Sizes

enum PixelFontSize {
    case small      // 10pt - labels, hints
    case medium     // 14pt - body text
    case large      // 18pt - headers
    case xlarge     // 24pt - titles

    var pointSize: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 14
        case .large: return 18
        case .xlarge: return 24
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .small: return 2
        case .medium: return 3
        case .large: return 4
        case .xlarge: return 5
        }
    }
}
