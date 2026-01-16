import Foundation

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest
    case back
    case shoulders
    case biceps
    case triceps
    case core
    case legs
    case fullBody

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullBody: return "Full Body"
        default: return rawValue.capitalized
        }
    }

    var iconName: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "figure.boxing"
        case .triceps: return "figure.strengthtraining.functional"
        case .core: return "figure.core.training"
        case .legs: return "figure.walk"
        case .fullBody: return "figure.mixed.cardio"
        }
    }
}
