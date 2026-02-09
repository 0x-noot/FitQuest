import SwiftUI
import SwiftData
import CloudKit

struct ClubMembersView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player
    @Bindable var club: Club

    @State private var members: [ClubMember] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: PixelScale.px(1)) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(PixelTheme.text)
                }
                Spacer()
                Button(action: loadMembers) {
                    PixelIconView(icon: .bolt, size: 20, color: PixelTheme.text)
                }
            }
            .padding(.horizontal, PixelScale.px(4))
            .padding(.top, PixelScale.px(2))

            // Title Header
            VStack(spacing: PixelScale.px(2)) {
                PixelIconView(icon: .group, size: 48, color: PixelTheme.gbLightest)
                PixelText("MEMBERS", size: .large)
                PixelText(club.memberCountText, size: .small, color: PixelTheme.textSecondary)
            }
            .padding(PixelScale.px(4))

            // Members list
            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: PixelTheme.text))
                PixelText("LOADING...", size: .small, color: PixelTheme.textSecondary)
                Spacer()
            } else if members.isEmpty {
                Spacer()
                PixelText("NO MEMBERS FOUND", size: .medium, color: PixelTheme.textSecondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: PixelScale.px(1)) {
                        ForEach(members) { member in
                            PixelMemberRow(
                                member: member,
                                isCurrentUser: member.userID == player.appleUserID,
                                showRemoveButton: club.isOwner && member.userID != player.appleUserID,
                                onRemove: {
                                    removeMember(member)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, PixelScale.px(4))
                }
            }
        }
        .background(PixelTheme.background)
        .presentationBackground(PixelTheme.background)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadMembers()
        }
    }

    // MARK: - Actions

    private func loadMembers() {
        guard let userID = player.appleUserID else { return }

        isLoading = true

        Task {
            do {
                guard let record = try await CloudKitService.shared.fetchClubByRecordName(club.cloudKitRecordName) else {
                    await MainActor.run {
                        isLoading = false
                    }
                    return
                }

                let memberIDs = record["memberUserIDs"] as? [String] ?? []
                let ownerID = record["ownerUserID"] as? String ?? ""

                // Fetch leaderboard to get stats
                let leaderboardEntries = try await CloudKitService.shared.fetchLeaderboard(
                    clubRecordName: club.cloudKitRecordName,
                    currentUserID: userID
                )

                await MainActor.run {
                    var fetchedMembers: [ClubMember] = []

                    for memberID in memberIDs {
                        let leaderboardEntry = leaderboardEntries.first { $0.userID == memberID }

                        let member = ClubMember(
                            id: memberID,
                            userID: memberID,
                            displayName: leaderboardEntry?.displayName ?? "Member",
                            isOwner: memberID == ownerID,
                            weeklyXP: leaderboardEntry?.weeklyXP ?? 0,
                            currentStreak: leaderboardEntry?.currentStreak ?? 0
                        )
                        fetchedMembers.append(member)
                    }

                    // Sort: owner first, then by XP
                    members = fetchedMembers.sorted { m1, m2 in
                        if m1.isOwner { return true }
                        if m2.isOwner { return false }
                        return m1.weeklyXP > m2.weeklyXP
                    }

                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func removeMember(_ member: ClubMember) {
        // Note: Implement member removal in CloudKitService
        // For now, just show error
        errorMessage = "Member removal not yet implemented"
        showError = true
    }
}

#Preview {
    ClubMembersView(
        player: Player(name: "Test"),
        club: Club(
            cloudKitRecordName: "test",
            name: "Fitness Warriors",
            description: "",
            inviteCode: "ABC123",
            isOwner: true,
            memberCount: 5
        )
    )
    .modelContainer(for: [Player.self, Club.self], inMemory: true)
}
