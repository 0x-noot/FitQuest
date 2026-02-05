import SwiftUI

struct PixelClubCard: View {
    let club: Club
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PixelScale.px(3)) {
                // Club icon
                PixelIconView(icon: .group, size: 32, color: PixelTheme.gbLightest)
                    .padding(PixelScale.px(2))
                    .background(PixelTheme.gbDark)
                    .pixelOutline()

                // Club info
                VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                    PixelText(club.name.uppercased(), size: .medium)

                    HStack(spacing: PixelScale.px(2)) {
                        PixelText(club.memberCountText, size: .small, color: PixelTheme.textSecondary)

                        if club.isOwner {
                            PixelText("OWNER", size: .small, color: Color(hex: "FFE66D"))
                        }
                    }
                }

                Spacer()

                // Arrow indicator
                PixelIconView(icon: .arrow, size: 16, color: PixelTheme.textSecondary)
            }
            .padding(PixelScale.px(3))
            .background(isPressed ? PixelTheme.gbDark : PixelTheme.cardBackground)
            .pixelOutline()
            .offset(y: isPressed ? PixelScale.px(1) : 0)
        }
        .buttonStyle(PixelPressStyle(isPressed: $isPressed))
    }
}

struct PixelClubSearchCard: View {
    let club: ClubSearchResult
    let onJoin: () -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: PixelScale.px(3)) {
            // Club icon
            PixelIconView(icon: .group, size: 28, color: PixelTheme.gbLightest)
                .padding(PixelScale.px(2))
                .background(PixelTheme.gbDark)
                .pixelOutline()

            // Club info
            VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                PixelText(club.name.uppercased(), size: .medium)

                HStack(spacing: PixelScale.px(2)) {
                    PixelText(club.memberCountText, size: .small, color: PixelTheme.textSecondary)
                }

                if !club.description.isEmpty {
                    PixelText(club.description.uppercased().prefix(40) + (club.description.count > 40 ? "..." : ""), size: .small, color: PixelTheme.textSecondary)
                }
            }

            Spacer()

            // Join button
            if club.isFull {
                PixelText("FULL", size: .small, color: PixelTheme.textSecondary)
            } else {
                Button(action: onJoin) {
                    PixelText("JOIN", size: .small, color: PixelTheme.gbLightest)
                        .padding(.horizontal, PixelScale.px(2))
                        .padding(.vertical, PixelScale.px(1))
                        .background(isPressed ? PixelTheme.gbDarkest : PixelTheme.gbDark)
                        .pixelOutline()
                }
                .buttonStyle(PixelPressStyle(isPressed: $isPressed))
            }
        }
        .padding(PixelScale.px(3))
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }
}

#Preview {
    VStack(spacing: 16) {
        PixelClubCard(
            club: Club(
                cloudKitRecordName: "test",
                name: "Fitness Warriors",
                description: "A club for fitness enthusiasts",
                inviteCode: "ABC123",
                isOwner: true,
                memberCount: 15,
                maxMembers: 50
            ),
            onTap: {}
        )

        PixelClubSearchCard(
            club: ClubSearchResult(
                id: "1",
                recordName: "test",
                name: "Morning Runners",
                description: "We run every morning at 6am!",
                memberCount: 42,
                maxMembers: 50,
                isPublic: true
            ),
            onJoin: {}
        )
    }
    .padding()
    .background(PixelTheme.background)
}
