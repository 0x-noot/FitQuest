import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme (Game Boy Pixel Art Style)
// All colors now use the authentic Game Boy DMG-01 4-shade green palette

struct Theme {
    // MARK: - Backgrounds (Game Boy Green)
    static let background = PixelTheme.background
    static let cardBackground = PixelTheme.cardBackground
    static let elevated = PixelTheme.elevated

    // MARK: - Accents (Mapped to Game Boy shades)
    // In the Game Boy palette, we use different shades for emphasis
    static let primary = PixelTheme.gbDarkest      // Primary actions
    static let secondary = PixelTheme.gbDark       // Secondary actions
    static let success = PixelTheme.gbDarkest      // Success states
    static let warning = PixelTheme.gbDark         // Warning states
    static let streak = PixelTheme.gbDarkest       // Streak indicators

    // MARK: - Text
    static let textPrimary = PixelTheme.text
    static let textSecondary = PixelTheme.textSecondary
    static let textMuted = PixelTheme.gbDark

    // MARK: - XP Bar
    static let xpBarBackground = PixelTheme.gbLight

    // MARK: - Gradients (Solid colors in pixel art style)
    // Game Boy doesn't have gradients, so we use solid fills
    static let primaryGradient = LinearGradient(
        colors: [PixelTheme.gbDarkest, PixelTheme.gbDarkest],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let xpBarGradient = LinearGradient(
        colors: [PixelTheme.gbDarkest, PixelTheme.gbDarkest],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let streakGradient = LinearGradient(
        colors: [PixelTheme.gbDarkest, PixelTheme.gbDarkest],
        startPoint: .top,
        endPoint: .bottom
    )
}
