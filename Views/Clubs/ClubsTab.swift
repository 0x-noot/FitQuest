import SwiftUI
import SwiftData
import CloudKit

struct ClubsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player

    @State private var showCreateClub = false
    @State private var showJoinClub = false
    @State private var selectedClub: Club?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                PixelText("CLUBS", size: .xlarge)
                Spacer()
            }
            .padding(.horizontal, PixelScale.px(4))
            .padding(.top, PixelScale.px(2))
            .padding(.bottom, PixelScale.px(3))

            if (player.clubs ?? []).isEmpty {
                emptyState
            } else {
                clubsList
            }

            Spacer()

            // Action buttons
            actionButtons
        }
        .background(PixelTheme.background)
        .sheet(isPresented: $showCreateClub) {
            CreateClubSheet(player: player, onCreated: { club in
                showCreateClub = false
                selectedClub = club
            })
        }
        .sheet(isPresented: $showJoinClub) {
            JoinClubSheet(player: player, onJoined: { club in
                showJoinClub = false
                selectedClub = club
            })
        }
        .sheet(item: $selectedClub) { club in
            ClubDetailView(player: player, club: club)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            refreshClubs()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PixelScale.px(4)) {
            Spacer()

            PixelIconView(icon: .group, size: 64, color: PixelTheme.textSecondary)

            VStack(spacing: PixelScale.px(2)) {
                PixelText("NO CLUBS YET", size: .large)
                PixelText("JOIN OR CREATE A CLUB TO", size: .small, color: PixelTheme.textSecondary)
                PixelText("COMPETE WITH FRIENDS!", size: .small, color: PixelTheme.textSecondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Clubs List

    private var clubsList: some View {
        ScrollView {
            VStack(spacing: PixelScale.px(2)) {
                ForEach((player.clubs ?? []).sorted(by: { $0.joinedAt > $1.joinedAt })) { club in
                    PixelClubCard(club: club) {
                        selectedClub = club
                    }
                }
            }
            .padding(.horizontal, PixelScale.px(4))
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: PixelScale.px(2)) {
            HStack(spacing: PixelScale.px(2)) {
                PixelButton("CREATE", icon: .plus, style: .primary) {
                    if player.canCreateMoreClubs {
                        showCreateClub = true
                    } else {
                        errorMessage = "You can only be in \(ClubManager.maxClubsPerUser) clubs at a time."
                        showError = true
                    }
                }

                PixelButton("JOIN", icon: .group, style: .secondary) {
                    if player.canJoinMoreClubs {
                        showJoinClub = true
                    } else {
                        errorMessage = "You can only be in \(ClubManager.maxClubsPerUser) clubs at a time."
                        showError = true
                    }
                }
            }

            PixelText("\(player.clubCount)/\(ClubManager.maxClubsPerUser) CLUBS", size: .small, color: PixelTheme.textSecondary)
        }
        .padding(PixelScale.px(4))
    }

    // MARK: - Helpers

    private func refreshClubs() {
        guard let userID = player.appleUserID else { return }

        isLoading = true

        Task {
            do {
                let clubRecords = try await CloudKitService.shared.fetchUserClubs(userID: userID)

                await MainActor.run {
                    for record in clubRecords {
                        let recordName = record.recordID.recordName

                        if !(player.clubs ?? []).contains(where: { $0.cloudKitRecordName == recordName }) {
                            let ownerID = record["ownerUserID"] as? String ?? ""
                            let club = Club(
                                cloudKitRecordName: recordName,
                                name: record["name"] as? String ?? "",
                                description: record["description"] as? String ?? "",
                                inviteCode: record["inviteCode"] as? String ?? "",
                                isOwner: ownerID == userID,
                                memberCount: record["memberCount"] as? Int ?? 1,
                                maxMembers: record["maxMembers"] as? Int ?? 50,
                                isPublic: (record["isPublic"] as? Int ?? 0) == 1
                            )
                            modelContext.insert(club)
                            player.clubs?.append(club)
                        } else if let existingClub = (player.clubs ?? []).first(where: { $0.cloudKitRecordName == recordName }) {
                            existingClub.memberCount = record["memberCount"] as? Int ?? existingClub.memberCount
                            existingClub.name = record["name"] as? String ?? existingClub.name
                        }
                    }

                    let remoteRecordNames = Set(clubRecords.map { $0.recordID.recordName })
                    for club in (player.clubs ?? []) where !remoteRecordNames.contains(club.cloudKitRecordName) {
                        modelContext.delete(club)
                    }

                    try? modelContext.save()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ClubsTab(player: Player(name: "Test"))
        .modelContainer(for: [Player.self, Club.self], inMemory: true)
}
