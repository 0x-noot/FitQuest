import SwiftUI

enum EvolutionStage: String, CaseIterable {
    case baby       // Level 1-5
    case child      // Level 6-15
    case teen       // Level 16-30
    case adult      // Level 31+

    static func from(level: Int) -> EvolutionStage {
        switch level {
        case 1...5: return .baby
        case 6...15: return .child
        case 16...30: return .teen
        default: return .adult
        }
    }

    var displayName: String {
        switch self {
        case .baby: return "Baby"
        case .child: return "Child"
        case .teen: return "Teen"
        case .adult: return "Adult"
        }
    }

    var description: String {
        switch self {
        case .baby: return "Just starting out! Needs lots of care."
        case .child: return "Growing stronger every day!"
        case .teen: return "Almost fully grown. Keep it up!"
        case .adult: return "Fully evolved! A powerful companion."
        }
    }

    // Level thresholds for evolution
    var levelRange: ClosedRange<Int> {
        switch self {
        case .baby: return 1...5
        case .child: return 6...15
        case .teen: return 16...30
        case .adult: return 31...999
        }
    }

    var nextStage: EvolutionStage? {
        switch self {
        case .baby: return .child
        case .child: return .teen
        case .teen: return .adult
        case .adult: return nil
        }
    }

    var levelToEvolve: Int? {
        nextStage?.levelRange.lowerBound
    }

    // Visual properties
    var iconScale: CGFloat {
        switch self {
        case .baby: return 0.6
        case .child: return 0.75
        case .teen: return 0.9
        case .adult: return 1.0
        }
    }

    var glowIntensity: Double {
        switch self {
        case .baby: return 0.0
        case .child: return 0.1
        case .teen: return 0.2
        case .adult: return 0.4
        }
    }

    var auraColor: Color {
        switch self {
        case .baby: return .clear
        case .child: return Theme.primary.opacity(0.1)
        case .teen: return Theme.primary.opacity(0.2)
        case .adult: return Theme.warning.opacity(0.3)
        }
    }

    var badgeColor: Color {
        switch self {
        case .baby: return Theme.textMuted
        case .child: return Theme.secondary
        case .teen: return Theme.primary
        case .adult: return Theme.warning
        }
    }
}

// MARK: - Species-Specific Evolution Icons

extension PetSpecies {
    func iconName(for stage: EvolutionStage) -> String {
        // For now, use the same icon but with visual scaling
        // In a full implementation, you could have different SF Symbols per stage
        switch self {
        case .plant:
            switch stage {
            case .baby: return "leaf"           // Small leaf (no fill)
            case .child: return "leaf.fill"     // Filled leaf
            case .teen: return "leaf.fill"      // Same, but scaled larger
            case .adult: return "leaf.circle.fill" // Leaf with circle
            }
        case .cat:
            return iconName  // cat.fill for all stages
        case .dog:
            return iconName  // dog.fill for all stages
        case .wolf:
            switch stage {
            case .baby: return "pawprint"       // Small paw (no fill)
            case .child: return "pawprint.fill" // Filled paw
            case .teen: return "pawprint.fill"  // Same, scaled
            case .adult: return "pawprint.circle.fill" // Paw with circle
            }
        case .dragon:
            switch stage {
            case .baby: return "flame"          // Small flame
            case .child: return "flame.fill"    // Filled flame
            case .teen: return "flame.fill"     // Same, scaled
            case .adult: return "flame.circle.fill" // Flame with circle
            }
        }
    }
}
