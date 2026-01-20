import SwiftUI

struct EssenceBadge: View {
    let amount: Int
    let size: BadgeSize

    enum BadgeSize {
        case small
        case medium
        case large

        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 14
            case .large: return 16
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 18
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 8
            case .large: return 10
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: size.iconSize))
                .foregroundColor(Theme.warning)

            Text("\(amount)")
                .font(.system(size: size.fontSize, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(.horizontal, size.padding + 4)
        .padding(.vertical, size.padding)
        .background(Theme.warning.opacity(0.15))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        EssenceBadge(amount: 150, size: .small)
        EssenceBadge(amount: 250, size: .medium)
        EssenceBadge(amount: 1250, size: .large)
    }
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
