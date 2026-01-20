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
}
