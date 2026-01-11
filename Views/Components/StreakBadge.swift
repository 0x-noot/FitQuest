import SwiftUI

struct StreakBadge: View {
    let currentStreak: Int
    let highestStreak: Int
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 12 : 16) {
            // Current streak
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: compact ? 14 : 18))
                        .foregroundStyle(Theme.streakGradient)

                    Text("\(currentStreak)")
                        .font(.system(size: compact ? 18 : 24, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                }

                if !compact {
                    Text("Current")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }
            }

            if !compact {
                Divider()
                    .frame(height: 30)
                    .background(Theme.elevated)
            }

            // Highest streak
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: compact ? 12 : 16))
                        .foregroundColor(Theme.warning)

                    Text("\(highestStreak)")
                        .font(.system(size: compact ? 16 : 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }

                if !compact {
                    Text("Best")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }
            }
        }
        .padding(.horizontal, compact ? 12 : 20)
        .padding(.vertical, compact ? 8 : 12)
        .background(Theme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakBadge(currentStreak: 7, highestStreak: 14)
        StreakBadge(currentStreak: 7, highestStreak: 14, compact: true)
    }
    .padding()
    .background(Theme.background)
}
