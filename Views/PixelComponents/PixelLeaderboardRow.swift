import SwiftUI

struct PixelLeaderboardRow: View {
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: PixelScale.px(2)) {
            // Rank
            ZStack {
                if entry.rank <= 3 {
                    PixelIconView(icon: .trophy, size: 20, color: rankColor)
                }
                PixelText(ClubManager.formatRank(entry.rank), size: .small, color: rankColor)
                    .offset(y: entry.rank <= 3 ? PixelScale.px(3) : 0)
            }
            .frame(width: PixelScale.px(8))

            // Name
            VStack(alignment: .leading, spacing: 0) {
                PixelText(entry.displayName.uppercased(), size: .medium, color: entry.isCurrentUser ? Color(hex: "4ECDC4") : PixelTheme.text)

                if entry.currentStreak > 0 {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .flame, size: 10, color: Color(hex: "FF6B35"))
                        PixelText("\(entry.currentStreak)", size: .small, color: PixelTheme.textSecondary)
                    }
                }
            }

            Spacer()

            // Stats
            VStack(alignment: .trailing, spacing: 0) {
                HStack(spacing: PixelScale.px(1)) {
                    PixelText("\(entry.weeklyXP)", size: .medium, color: Color(hex: "4ECDC4"))
                    PixelText("XP", size: .small, color: PixelTheme.textSecondary)
                }

                PixelText("\(entry.weeklyWorkouts) WORKOUTS", size: .small, color: PixelTheme.textSecondary)
            }
        }
        .padding(PixelScale.px(2))
        .background(entry.isCurrentUser ? PixelTheme.gbDarkest.opacity(0.3) : Color.clear)
        .pixelOutline(color: entry.isCurrentUser ? PixelTheme.border : Color.clear)
    }

    private var rankColor: Color {
        switch entry.rank {
        case 1: return Color(hex: "FFD700")
        case 2: return Color(hex: "C0C0C0")
        case 3: return Color(hex: "CD7F32")
        default: return PixelTheme.textSecondary
        }
    }
}

#Preview {
    VStack(spacing: 4) {
        PixelLeaderboardRow(
            entry: LeaderboardEntry(
                userID: "user1",
                displayName: "Champion",
                weeklyXP: 1250,
                weeklyWorkouts: 7,
                currentStreak: 14,
                rank: 1,
                isCurrentUser: false
            )
        )

        PixelLeaderboardRow(
            entry: LeaderboardEntry(
                userID: "user2",
                displayName: "You",
                weeklyXP: 980,
                weeklyWorkouts: 5,
                currentStreak: 7,
                rank: 2,
                isCurrentUser: true
            )
        )

        PixelLeaderboardRow(
            entry: LeaderboardEntry(
                userID: "user3",
                displayName: "Bronze Star",
                weeklyXP: 750,
                weeklyWorkouts: 4,
                currentStreak: 3,
                rank: 3,
                isCurrentUser: false
            )
        )

        PixelLeaderboardRow(
            entry: LeaderboardEntry(
                userID: "user4",
                displayName: "Regular Joe",
                weeklyXP: 450,
                weeklyWorkouts: 3,
                currentStreak: 1,
                rank: 4,
                isCurrentUser: false
            )
        )
    }
    .padding()
    .background(PixelTheme.background)
}
