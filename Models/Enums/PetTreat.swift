import Foundation
import SwiftUI

enum PetTreat: String, CaseIterable {
    case small
    case medium
    case large

    var displayName: String {
        switch self {
        case .small: return "Small Treat"
        case .medium: return "Medium Treat"
        case .large: return "Large Treat"
        }
    }

    var essenceCost: Int {
        switch self {
        case .small: return 10
        case .medium: return 25
        case .large: return 50
        }
    }

    var happinessBoost: Double {
        switch self {
        case .small: return 5.0    // +5%
        case .medium: return 15.0  // +15%
        case .large: return 30.0   // +30%
        }
    }

    var iconName: String {
        "heart.fill"
    }

    var iconColor: Color {
        switch self {
        case .small: return Color.pink
        case .medium: return Color.red
        case .large: return Theme.primary
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small: return 18
        case .medium: return 24
        case .large: return 32
        }
    }

    var description: String {
        switch self {
        case .small: return "A small snack to cheer up your pet"
        case .medium: return "A tasty meal for your companion"
        case .large: return "A feast that makes your pet ecstatic!"
        }
    }
}
