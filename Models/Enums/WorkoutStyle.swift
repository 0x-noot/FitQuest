import Foundation

enum WorkoutStyle: String, Codable, CaseIterable, Identifiable {
    case weights
    case cardio
    case balanced
    case notSure = "not_sure"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weights: return "Weights & Strength"
        case .cardio: return "Cardio & Endurance"
        case .balanced: return "Balanced Mix"
        case .notSure: return "Not sure yet"
        }
    }

    var iconName: String {
        switch self {
        case .weights: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .balanced: return "circle.grid.2x2.fill"
        case .notSure: return "questionmark.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .weights: return "Focus on building strength and muscle"
        case .cardio: return "Focus on heart health and endurance"
        case .balanced: return "Mix of strength and cardio training"
        case .notSure: return "We'll help you figure it out!"
        }
    }
}
