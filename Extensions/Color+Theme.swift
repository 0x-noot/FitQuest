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

struct Theme {
    // Backgrounds
    static let background = Color(hex: "0D0D0F")
    static let cardBackground = Color(hex: "1A1A1F")
    static let elevated = Color(hex: "252530")

    // Accents
    static let primary = Color(hex: "8B5CF6")
    static let secondary = Color(hex: "22D3EE")
    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let streak = Color(hex: "F97316")

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9CA3AF")
    static let textMuted = Color(hex: "6B7280")

    // XP Bar
    static let xpBarBackground = Color(hex: "374151")

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "8B5CF6"), Color(hex: "6366F1")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let xpBarGradient = LinearGradient(
        colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let streakGradient = LinearGradient(
        colors: [Color(hex: "F97316"), Color(hex: "EF4444")],
        startPoint: .top,
        endPoint: .bottom
    )
}
