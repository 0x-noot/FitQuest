import Foundation

enum PremiumFeature: String, CaseIterable {
    case noAds = "NO ADS"
    case workoutPlans = "WORKOUT PLANS"
    case clubs = "CREATE & JOIN CLUBS"
    case fullEssence = "2X ESSENCE RATE"

    var icon: PixelIcon {
        switch self {
        case .noAds: return .star
        case .workoutPlans: return .dumbbell
        case .clubs: return .group
        case .fullEssence: return .sparkle
        }
    }

    var featureDescription: String {
        switch self {
        case .noAds: return "REMOVE ALL ADS"
        case .workoutPlans: return "PERSONALIZED WEEKLY PLANS"
        case .clubs: return "CREATE AND JOIN FITNESS CLUBS"
        case .fullEssence: return "EARN DOUBLE ESSENCE FROM WORKOUTS"
        }
    }
}
