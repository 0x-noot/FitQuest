import Foundation
import SwiftUI

enum QuestType: String, Codable, CaseIterable {
    case earlyBird          // Complete a workout before 9 AM
    case nightOwl           // Complete a workout after 9 PM
    case doubleDown         // Complete 2 workouts today
    case petCare            // Feed your pet a treat
    case strengthFocus      // Complete a strength workout
    case cardioFocus        // Complete a cardio workout
    case streakKeeper       // Maintain your streak (complete any workout)
    case happyPet           // Get pet happiness above 80%
    case playTime           // Play with your pet

    var displayName: String {
        switch self {
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .doubleDown: return "Double Down"
        case .petCare: return "Pet Care"
        case .strengthFocus: return "Strength Focus"
        case .cardioFocus: return "Cardio Focus"
        case .streakKeeper: return "Streak Keeper"
        case .happyPet: return "Happy Pet"
        case .playTime: return "Play Time"
        }
    }

    var description: String {
        switch self {
        case .earlyBird: return "Complete a workout before 9 AM"
        case .nightOwl: return "Complete a workout after 9 PM"
        case .doubleDown: return "Complete 2 workouts today"
        case .petCare: return "Feed your pet a treat"
        case .strengthFocus: return "Complete a strength workout"
        case .cardioFocus: return "Complete a cardio workout"
        case .streakKeeper: return "Complete any workout today"
        case .happyPet: return "Get pet happiness above 80%"
        case .playTime: return "Play with your pet"
        }
    }

    var iconName: String {
        switch self {
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.stars.fill"
        case .doubleDown: return "2.circle.fill"
        case .petCare: return "heart.fill"
        case .strengthFocus: return "dumbbell.fill"
        case .cardioFocus: return "figure.run"
        case .streakKeeper: return "flame.fill"
        case .happyPet: return "face.smiling.fill"
        case .playTime: return "hand.tap.fill"
        }
    }

    var color: Color {
        switch self {
        case .earlyBird: return .orange
        case .nightOwl: return .indigo
        case .doubleDown: return Theme.primary
        case .petCare: return Theme.secondary
        case .strengthFocus: return .red
        case .cardioFocus: return .green
        case .streakKeeper: return Theme.warning
        case .happyPet: return .pink
        case .playTime: return .cyan
        }
    }

    // Reward type and amount
    var rewardType: QuestRewardType {
        switch self {
        case .earlyBird, .nightOwl, .strengthFocus, .cardioFocus, .streakKeeper:
            return .xp
        case .doubleDown, .petCare, .happyPet, .playTime:
            return .essence
        }
    }

    var rewardAmount: Int {
        switch self {
        case .earlyBird: return 50
        case .nightOwl: return 50
        case .doubleDown: return 30
        case .petCare: return 20
        case .strengthFocus: return 40
        case .cardioFocus: return 40
        case .streakKeeper: return 25
        case .happyPet: return 25
        case .playTime: return 15
        }
    }

    // Target for progress tracking
    var target: Int {
        switch self {
        case .doubleDown: return 2
        case .playTime: return 1
        default: return 1
        }
    }

    // Difficulty weighting (for random selection)
    var difficulty: QuestDifficulty {
        switch self {
        case .earlyBird, .nightOwl: return .medium
        case .doubleDown: return .hard
        case .petCare, .playTime: return .easy
        case .strengthFocus, .cardioFocus: return .medium
        case .streakKeeper: return .easy
        case .happyPet: return .medium
        }
    }
}

enum QuestRewardType: String, Codable {
    case xp
    case essence

    var iconName: String {
        switch self {
        case .xp: return "star.fill"
        case .essence: return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .xp: return Theme.warning
        case .essence: return Theme.secondary
        }
    }
}

enum QuestDifficulty: Int, Codable {
    case easy = 1
    case medium = 2
    case hard = 3
}
