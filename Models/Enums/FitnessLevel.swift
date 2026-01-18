import Foundation

enum FitnessLevel: String, Codable, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }

    var iconName: String {
        switch self {
        case .beginner: return "leaf.fill"
        case .intermediate: return "flame.fill"
        case .advanced: return "bolt.fill"
        }
    }

    var description: String {
        switch self {
        case .beginner: return "New to working out or returning after a break"
        case .intermediate: return "Work out regularly, comfortable with most exercises"
        case .advanced: return "Very experienced with structured training"
        }
    }
}
