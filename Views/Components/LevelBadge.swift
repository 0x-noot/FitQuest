import SwiftUI

struct LevelBadge: View {
    let level: Int
    var size: Size = .medium

    enum Size {
        case small, medium, large

        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 20
            case .large: return 28
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 10
            case .large: return 14
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 14
            case .large: return 18
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: size.iconSize))
                .foregroundColor(Theme.warning)

            Text("Lv.\(level)")
                .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding * 0.6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Theme.primary.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        LevelBadge(level: 12, size: .small)
        LevelBadge(level: 12, size: .medium)
        LevelBadge(level: 12, size: .large)
    }
    .padding()
    .background(Theme.background)
}
