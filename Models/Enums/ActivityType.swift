import Foundation
import SwiftUI

enum ActivityType: String, Codable, CaseIterable {
    case workout = "workout"
    case joined = "joined"
    case levelUp = "levelUp"
    case evolution = "evolution"
    case streak = "streak"

    var displayName: String {
        switch self {
        case .workout:
            return "Workout"
        case .joined:
            return "Joined"
        case .levelUp:
            return "Level Up"
        case .evolution:
            return "Evolution"
        case .streak:
            return "Streak"
        }
    }

    var iconName: String {
        switch self {
        case .workout:
            return "flame.fill"
        case .joined:
            return "person.badge.plus"
        case .levelUp:
            return "arrow.up.circle.fill"
        case .evolution:
            return "sparkles"
        case .streak:
            return "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .workout:
            return Color(hex: "FF6B35")
        case .joined:
            return Color(hex: "4ECDC4")
        case .levelUp:
            return Color(hex: "FFE66D")
        case .evolution:
            return Color(hex: "A855F7")
        case .streak:
            return Color(hex: "F59E0B")
        }
    }
}
