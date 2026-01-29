import SwiftUI

/// Purple/Violet dark mode palette
/// Used throughout the app for the pixel art Tamagotchi aesthetic
struct PixelTheme {
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
