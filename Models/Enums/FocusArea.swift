import Foundation

enum FocusArea: String, Codable, CaseIterable, Identifiable {
    case chest
    case back
    case shoulders
    case arms
    case core
    case legs
    case glutes
    case fullBody = "full_body"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .shoulders: return "Shoulders"
        case .arms: return "Arms"
        case .core: return "Core"
        case .legs: return "Legs"
        case .glutes: return "Glutes"
        case .fullBody: return "Full Body"
        }
    }

    var iconName: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .back: return "figure.stand"
        case .shoulders: return "figure.wave"
        case .arms: return "figure.boxing"
        case .core: return "figure.core.training"
        case .legs: return "figure.walk"
        case .glutes: return "figure.strengthtraining.traditional"
        case .fullBody: return "figure.mixed.cardio"
        }
    }

    var description: String {
        switch self {
        case .chest: return "Pecs and upper chest"
        case .back: return "Lats and upper back"
        case .shoulders: return "Deltoids and traps"
        case .arms: return "Biceps and triceps"
        case .core: return "Abs and obliques"
        case .legs: return "Quads and hamstrings"
        case .glutes: return "Glutes and hip muscles"
        case .fullBody: return "All major muscle groups"
        }
    }

    /// Maps FocusArea to the corresponding MuscleGroup(s) used by WorkoutTemplates
    var muscleGroups: [MuscleGroup] {
        switch self {
        case .chest: return [.chest]
        case .back: return [.back]
        case .shoulders: return [.shoulders]
        case .arms: return [.biceps, .triceps]
        case .core: return [.core]
        case .legs: return [.legs]
        case .glutes: return [.legs]
        case .fullBody: return MuscleGroup.allCases
        }
    }
}
