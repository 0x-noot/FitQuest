import Foundation

enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
    case buildMuscle = "build_muscle"
    case loseWeight = "lose_weight"
    case improveCardio = "improve_cardio"
    case buildHabit = "build_habit"
    case increaseEnergy = "increase_energy"
    case trainForEvent = "train_for_event"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .buildMuscle: return "Build muscle & strength"
        case .loseWeight: return "Lose weight"
        case .improveCardio: return "Improve cardio"
        case .buildHabit: return "Build a workout habit"
        case .increaseEnergy: return "Increase energy"
        case .trainForEvent: return "Train for an event"
        }
    }

    var iconName: String {
        switch self {
        case .buildMuscle: return "dumbbell.fill"
        case .loseWeight: return "scalemass.fill"
        case .improveCardio: return "heart.fill"
        case .buildHabit: return "calendar.badge.checkmark"
        case .increaseEnergy: return "bolt.fill"
        case .trainForEvent: return "flag.fill"
        }
    }

    var description: String {
        switch self {
        case .buildMuscle: return "Get stronger and build lean muscle"
        case .loseWeight: return "Burn calories and shed pounds"
        case .improveCardio: return "Boost endurance and heart health"
        case .buildHabit: return "Create a consistent routine"
        case .increaseEnergy: return "Feel more energized daily"
        case .trainForEvent: return "Prepare for a race or competition"
        }
    }
}
