import SwiftUI

struct RankBadge: View {
    let rank: PlayerRank
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small, medium, large

        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 24
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 16
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            case .large: return 12
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            case .large: return 12
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: rank.iconName)
                .font(.system(size: size.iconSize, weight: .bold))

            Text(rank.displayName)
                .font(.system(size: size.fontSize, weight: .bold))
        }
        .foregroundStyle(rank.gradient)
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding * 0.6)
        .background(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(rank.color.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .strokeBorder(rank.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// Compact version showing just the icon
struct RankIcon: View {
    let rank: PlayerRank
    var size: CGFloat = 24

    var body: some View {
        ZStack {
            Circle()
                .fill(rank.gradient)
                .frame(width: size, height: size)

            Image(systemName: rank.iconName)
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ForEach(PlayerRank.allCases) { rank in
            HStack(spacing: 16) {
                RankBadge(rank: rank, size: .small)
                RankBadge(rank: rank, size: .medium)
                RankBadge(rank: rank, size: .large)
                RankIcon(rank: rank)
            }
        }
    }
    .padding()
    .background(Color(red: 0.05, green: 0.05, blue: 0.06))
}
