import SwiftUI
import SwiftData

struct ClubDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player
    @Bindable var club: Club

    @State private var activities: [ClubActivity] = []
    @State private var isLoadingActivities = false
    @State private var showLeaderboard = false
    @State private var showMembers = false
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                clubHeader

                // Activity Feed
                activityFeed
            }
            .background(PixelTheme.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .foregroundColor(PixelTheme.text)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        PixelIconView(icon: .settings, size: 20, color: PixelTheme.text)
                    }
                }
            }
            .sheet(isPresented: $showLeaderboard) {
                ClubLeaderboardView(player: player, club: club)
            }
            .sheet(isPresented: $showMembers) {
                ClubMembersView(player: player, club: club)
            }
            .sheet(isPresented: $showSettings) {
                ClubSettingsSheet(player: player, club: club, onLeave: {
                    dismiss()
                })
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadActivities()
        }
    }

    // MARK: - Club Header

    private var clubHeader: some View {
        VStack(spacing: PixelScale.px(3)) {
            // Club name and info
            VStack(spacing: PixelScale.px(1)) {
                PixelText(club.name.uppercased(), size: .xlarge)

                HStack(spacing: PixelScale.px(2)) {
                    PixelText(club.memberCountText, size: .small, color: PixelTheme.textSecondary)

                    if club.isPublic {
                        PixelText("PUBLIC", size: .small, color: Color(hex: "4ECDC4"))
                    } else {
                        PixelText("PRIVATE", size: .small, color: PixelTheme.textSecondary)
                    }
                }

                if !club.clubDescription.isEmpty {
                    PixelText(club.clubDescription.uppercased(), size: .small, color: PixelTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, PixelScale.px(1))
                }
            }

            // Action buttons
            HStack(spacing: PixelScale.px(2)) {
                PixelButton("LEADERBOARD", icon: .trophy, style: .secondary) {
                    showLeaderboard = true
                }

                PixelButton("MEMBERS", icon: .group, style: .secondary) {
                    showMembers = true
                }
            }
            .padding(.horizontal, PixelScale.px(4))

            // Invite code (for members)
            if !club.inviteCode.isEmpty {
                HStack(spacing: PixelScale.px(2)) {
                    PixelText("INVITE CODE:", size: .small, color: PixelTheme.textSecondary)
                    PixelText(club.inviteCode, size: .small, color: PixelTheme.gbLightest)

                    Button(action: copyInviteCode) {
                        PixelIconView(icon: .plus, size: 12, color: PixelTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(PixelScale.px(2))
                .background(PixelTheme.cardBackground)
                .pixelOutline()
            }
        }
        .padding(PixelScale.px(4))
        .background(PixelTheme.cardBackground)
    }

    // MARK: - Activity Feed

    private var activityFeed: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                PixelText("ACTIVITY", size: .medium)
                Spacer()

                if isLoadingActivities {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: PixelTheme.text))
                        .scaleEffect(0.6)
                } else {
                    Button(action: loadActivities) {
                        PixelText("REFRESH", size: .small, color: PixelTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, PixelScale.px(4))
            .padding(.vertical, PixelScale.px(2))

            // Activities list
            if activities.isEmpty && !isLoadingActivities {
                VStack(spacing: PixelScale.px(2)) {
                    Spacer()
                    PixelText("NO ACTIVITY YET", size: .medium, color: PixelTheme.textSecondary)
                    PixelText("COMPLETE A WORKOUT TO", size: .small, color: PixelTheme.textSecondary)
                    PixelText("START THE ACTION!", size: .small, color: PixelTheme.textSecondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: PixelScale.px(1)) {
                        ForEach(activities) { activity in
                            PixelActivityRow(activity: activity)
                        }
                    }
                    .padding(.horizontal, PixelScale.px(4))
                }
            }
        }
    }

    // MARK: - Actions

    private func loadActivities() {
        guard let userID = player.appleUserID else { return }

        isLoadingActivities = true

        Task {
            do {
                let fetchedActivities = try await CloudKitService.shared.fetchRecentActivities(
                    clubRecordName: club.cloudKitRecordName,
                    limit: 50,
                    currentUserID: userID
                )

                await MainActor.run {
                    activities = fetchedActivities
                    isLoadingActivities = false
                }
            } catch {
                await MainActor.run {
                    isLoadingActivities = false
                }
            }
        }
    }

    private func copyInviteCode() {
        UIPasteboard.general.string = club.inviteCode
    }
}

#Preview {
    ClubDetailView(
        player: Player(name: "Test"),
        club: Club(
            cloudKitRecordName: "test",
            name: "Fitness Warriors",
            description: "A club for fitness enthusiasts",
            inviteCode: "ABC123",
            isOwner: true,
            memberCount: 15
        )
    )
    .modelContainer(for: [Player.self, Club.self, ClubActivity.self], inMemory: true)
}
