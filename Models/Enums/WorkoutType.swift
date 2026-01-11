import Foundation

enum WorkoutType: String, Codable, CaseIterable, Identifiable {
    case cardio
    case strength

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cardio: return "Cardio"
        case .strength: return "Strength"
        }
    }

    var iconName: String {
        switch self {
        case .cardio: return "figure.run"
        case .strength: return "dumbbell.fill"
        }
    }
}
