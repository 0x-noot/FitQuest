import SwiftUI

struct PixelActivityRow: View {
    let activity: ClubActivity

    var body: some View {
        HStack(alignment: .top, spacing: PixelScale.px(2)) {
            // Activity type icon
            PixelIconView(icon: iconForType, size: 20, color: activity.activityType.color)
                .padding(PixelScale.px(1))
                .background(PixelTheme.gbDarkest)
                .pixelOutline()

            VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                // Message
                PixelText(activity.message.uppercased(), size: .small)
                    .fixedSize(horizontal: false, vertical: true)

                // Time ago
                PixelText(ClubManager.timeAgoString(from: activity.timestamp), size: .small, color: PixelTheme.textSecondary)
            }

            Spacer()

            // XP earned (if applicable)
            if activity.xpEarned > 0 {
                HStack(spacing: PixelScale.px(1)) {
                    PixelText("+\(activity.xpEarned)", size: .small, color: Color(hex: "4ECDC4"))
                    PixelText("XP", size: .small, color: PixelTheme.textSecondary)
                }
            }
        }
        .padding(PixelScale.px(2))
        .background(activity.isOwnActivity ? PixelTheme.gbDarkest.opacity(0.3) : Color.clear)
        .pixelOutline(color: activity.isOwnActivity ? PixelTheme.border : Color.clear)
    }

    private var iconForType: PixelIcon {
        switch activity.activityType {
        case .workout:
            return .dumbbell
        case .joined:
            return .person
        case .levelUp:
            return .star
        case .evolution:
            return .sparkle
        case .streak:
            return .flame
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        PixelActivityRow(
            activity: ClubActivity(
                type: .workout,
                userID: "user1",
                displayName: "John",
                xpEarned: 150,
                message: "John completed a workout and earned 150 XP",
                isOwnActivity: true
            )
        )

        PixelActivityRow(
            activity: ClubActivity(
                type: .joined,
                userID: "user2",
                displayName: "Sarah",
                message: "Sarah joined the club",
                isOwnActivity: false
            )
        )

        PixelActivityRow(
            activity: ClubActivity(
                type: .levelUp,
                userID: "user3",
                displayName: "Mike",
                message: "Mike's pet leveled up!",
                isOwnActivity: false
            )
        )
    }
    .padding()
    .background(PixelTheme.background)
}
