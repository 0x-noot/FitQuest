import Foundation
import SwiftUI

enum PetMood: String {
    case ecstatic    // 90-100%
    case happy       // 70-89%
    case content     // 50-69%
    case sad         // 30-49%
    case unhappy     // 10-29%
    case miserable   // 0-9%

    static func from(happiness: Double) -> PetMood {
        switch happiness {
        case 90...100: return .ecstatic
        case 70..<90: return .happy
        case 50..<70: return .content
        case 30..<50: return .sad
        case 10..<30: return .unhappy
        default: return .miserable
        }
    }

    var emoji: String {
        switch self {
        case .ecstatic: return "🤩"
        case .happy: return "😊"
        case .content: return "😌"
        case .sad: return "😟"
        case .unhappy: return "😢"
        case .miserable: return "😭"
        }
    }

    var color: Color {
        switch self {
        case .ecstatic: return Theme.success
        case .happy: return Theme.primary
        case .content: return Theme.secondary
        case .sad: return Theme.warning
        case .unhappy: return Color.orange
        case .miserable: return Color.red
        }
    }

    var description: String {
        switch self {
        case .ecstatic: return "Ecstatic! XP bonus active!"
        case .happy: return "Happy and motivated"
        case .content: return "Content"
        case .sad: return "Feeling neglected"
        case .unhappy: return "Very unhappy"
        case .miserable: return "About to leave..."
        }
    }

    // Animation configuration for each mood
    var animationSpeed: Double {
        switch self {
        case .ecstatic: return 0.8   // Fast, energetic
        case .happy: return 1.2      // Medium-fast
        case .content: return 2.0    // Normal breathing
        case .sad: return 3.0        // Slow
        case .unhappy: return 4.0    // Very slow
        case .miserable: return 5.0  // Barely moving
        }
    }

    var bounceAmount: CGFloat {
        switch self {
        case .ecstatic: return 0.12   // Big bounces
        case .happy: return 0.08      // Medium bounces
        case .content: return 0.05    // Gentle breathing
        case .sad: return 0.03        // Minimal movement
        case .unhappy: return 0.02    // Very minimal
        case .miserable: return 0.01  // Almost still
        }
    }

    var rotationAmount: Double {
        switch self {
        case .ecstatic: return 5.0    // Slight wobble
        case .happy: return 3.0       // Small wobble
        case .content: return 0.0     // No rotation
        case .sad: return -3.0        // Droopy tilt
        case .unhappy: return -5.0    // More droopy
        case .miserable: return -8.0  // Very droopy
        }
    }

    var saturation: Double {
        switch self {
        case .ecstatic: return 1.2    // Extra vibrant
        case .happy: return 1.1       // Slightly vibrant
        case .content: return 1.0     // Normal
        case .sad: return 0.9         // Slightly muted
        case .unhappy: return 0.7     // Muted
        case .miserable: return 0.5   // Very muted/gray
        }
    }

    var idleAnimationType: IdleAnimationType {
        switch self {
        case .ecstatic: return .bounce
        case .happy: return .sway
        case .content: return .breathe
        case .sad: return .droop
        case .unhappy: return .shiver
        case .miserable: return .collapse
        }
    }
}

enum IdleAnimationType {
    case bounce    // Energetic up-down bouncing
    case sway      // Side-to-side swaying
    case breathe   // Gentle scale breathing
    case droop     // Slow downward drift
    case shiver    // Small rapid shaking
    case collapse  // Barely moving, gray overlay
}
