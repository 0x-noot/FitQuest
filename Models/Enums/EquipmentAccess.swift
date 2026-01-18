import Foundation

enum EquipmentAccess: String, Codable, CaseIterable, Identifiable {
    case fullGym = "full_gym"
    case homeGym = "home_gym"
    case bodyweight
    case cardioEquipment = "cardio_equipment"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullGym: return "Full Gym"
        case .homeGym: return "Home Gym"
        case .bodyweight: return "Bodyweight Only"
        case .cardioEquipment: return "Cardio Equipment"
        }
    }

    var iconName: String {
        switch self {
        case .fullGym: return "building.2.fill"
        case .homeGym: return "house.fill"
        case .bodyweight: return "figure.stand"
        case .cardioEquipment: return "figure.elliptical"
        }
    }

    var description: String {
        switch self {
        case .fullGym: return "Access to a full commercial gym"
        case .homeGym: return "Dumbbells, barbells, or machines at home"
        case .bodyweight: return "No equipment needed"
        case .cardioEquipment: return "Treadmill, bike, elliptical, etc."
        }
    }
}
