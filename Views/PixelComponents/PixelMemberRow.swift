import SwiftUI

struct PixelMemberRow: View {
    let member: ClubMember
    let isCurrentUser: Bool
    let showRemoveButton: Bool
    let onRemove: (() -> Void)?

    init(
        member: ClubMember,
        isCurrentUser: Bool = false,
        showRemoveButton: Bool = false,
        onRemove: (() -> Void)? = nil
    ) {
        self.member = member
        self.isCurrentUser = isCurrentUser
        self.showRemoveButton = showRemoveButton
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: PixelScale.px(2)) {
            // Avatar placeholder
            PixelIconView(icon: .person, size: 24, color: PixelTheme.gbLightest)
                .padding(PixelScale.px(1))
                .background(PixelTheme.gbDark)
                .pixelOutline()

            // Name and role
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: PixelScale.px(1)) {
                    PixelText(member.displayName.uppercased(), size: .medium, color: isCurrentUser ? Color(hex: "4ECDC4") : PixelTheme.text)

                    if member.isOwner {
                        PixelText("OWNER", size: .small, color: Color(hex: "FFE66D"))
                            .padding(.horizontal, PixelScale.px(1))
                            .background(PixelTheme.gbDarkest)
                            .pixelOutline()
                    }

                    if isCurrentUser {
                        PixelText("YOU", size: .small, color: Color(hex: "4ECDC4"))
                            .padding(.horizontal, PixelScale.px(1))
                            .background(PixelTheme.gbDarkest)
                            .pixelOutline()
                    }
                }

                // Stats
                HStack(spacing: PixelScale.px(2)) {
                    if member.weeklyXP > 0 {
                        HStack(spacing: PixelScale.px(1)) {
                            PixelText("\(member.weeklyXP)", size: .small, color: Color(hex: "4ECDC4"))
                            PixelText("XP", size: .small, color: PixelTheme.textSecondary)
                        }
                    }

                    if member.currentStreak > 0 {
                        HStack(spacing: PixelScale.px(1)) {
                            PixelIconView(icon: .flame, size: 10, color: Color(hex: "FF6B35"))
                            PixelText("\(member.currentStreak)", size: .small, color: PixelTheme.textSecondary)
                        }
                    }
                }
            }

            Spacer()

            // Remove button (for admins)
            if showRemoveButton && !member.isOwner && !isCurrentUser {
                Button(action: { onRemove?() }) {
                    PixelText("X", size: .small, color: Color(hex: "FF5555"))
                        .padding(PixelScale.px(1))
                        .background(PixelTheme.gbDarkest)
                        .pixelOutline()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(PixelScale.px(2))
        .background(isCurrentUser ? PixelTheme.gbDarkest.opacity(0.3) : Color.clear)
    }
}

#Preview {
    VStack(spacing: 4) {
        PixelMemberRow(
            member: ClubMember(
                id: "1",
                userID: "user1",
                displayName: "Club Owner",
                isOwner: true,
                weeklyXP: 1250,
                currentStreak: 14
            ),
            isCurrentUser: false
        )

        PixelMemberRow(
            member: ClubMember(
                id: "2",
                userID: "user2",
                displayName: "You",
                isOwner: false,
                weeklyXP: 800,
                currentStreak: 7
            ),
            isCurrentUser: true
        )

        PixelMemberRow(
            member: ClubMember(
                id: "3",
                userID: "user3",
                displayName: "Other Member",
                isOwner: false,
                weeklyXP: 450,
                currentStreak: 3
            ),
            isCurrentUser: false,
            showRemoveButton: true,
            onRemove: {}
        )
    }
    .padding()
    .background(PixelTheme.background)
}
