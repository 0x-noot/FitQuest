import SwiftUI
import SwiftData
import CloudKit

struct JoinClubSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player

    let onJoined: (Club) -> Void

    @State private var inviteCode = ""
    @State private var searchQuery = ""
    @State private var searchResults: [ClubSearchResult] = []
    @State private var isSearching = false
    @State private var isJoining = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                HStack(spacing: 0) {
                    tabButton("INVITE CODE", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    tabButton("SEARCH", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal, PixelScale.px(4))
                .padding(.top, PixelScale.px(2))

                if selectedTab == 0 {
                    inviteCodeView
                } else {
                    searchView
                }
            }
            .background(PixelTheme.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(PixelTheme.text)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Tab Button

    private func tabButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            PixelText(title, size: .small, color: isSelected ? PixelTheme.gbLightest : PixelTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, PixelScale.px(2))
                .background(isSelected ? PixelTheme.gbDark : Color.clear)
                .pixelOutline(color: isSelected ? PixelTheme.border : Color.clear)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Invite Code View

    private var inviteCodeView: some View {
        VStack(spacing: PixelScale.px(4)) {
            Spacer()

            PixelIconView(icon: .group, size: 48, color: PixelTheme.gbLightest)

            VStack(spacing: PixelScale.px(2)) {
                PixelText("ENTER INVITE CODE", size: .large)
                PixelText("GET THE CODE FROM A CLUB MEMBER", size: .small, color: PixelTheme.textSecondary)
            }

            // Code input
            TextField("", text: $inviteCode)
                .textFieldStyle(.plain)
                .font(.custom("Menlo", size: 24))
                .foregroundColor(PixelTheme.text)
                .textInputAutocapitalization(.characters)
                .multilineTextAlignment(.center)
                .onChange(of: inviteCode) { _, newValue in
                    inviteCode = ClubManager.formatInviteCode(newValue)
                }
                .padding(PixelScale.px(3))
                .frame(width: 200)
                .background(PixelTheme.cardBackground)
                .pixelOutline()

            PixelText("\(inviteCode.count)/\(ClubManager.inviteCodeLength)", size: .small, color: PixelTheme.textSecondary)

            Spacer()

            // Join button
            VStack(spacing: PixelScale.px(2)) {
                if isJoining {
                    HStack(spacing: PixelScale.px(2)) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: PixelTheme.text))
                            .scaleEffect(0.8)
                        PixelText("JOINING...", size: .small, color: PixelTheme.textSecondary)
                    }
                } else {
                    PixelButton("JOIN CLUB", style: .primary) {
                        joinWithCode()
                    }
                    .disabled(inviteCode.count != ClubManager.inviteCodeLength)
                    .opacity(inviteCode.count == ClubManager.inviteCodeLength ? 1 : 0.5)
                }
            }
            .padding(PixelScale.px(4))
        }
    }

    // MARK: - Search View

    private var searchView: some View {
        VStack(spacing: PixelScale.px(3)) {
            // Search field
            HStack(spacing: PixelScale.px(2)) {
                TextField("", text: $searchQuery, prompt: Text("SEARCH PUBLIC CLUBS").foregroundColor(PixelTheme.textSecondary))
                    .textFieldStyle(.plain)
                    .font(.custom("Menlo", size: 14))
                    .foregroundColor(PixelTheme.text)
                    .textInputAutocapitalization(.never)
                    .padding(PixelScale.px(2))
                    .background(PixelTheme.cardBackground)
                    .pixelOutline()

                Button(action: searchClubs) {
                    PixelIconView(icon: .arrow, size: 20, color: PixelTheme.gbLightest)
                        .padding(PixelScale.px(2))
                        .background(PixelTheme.gbDark)
                        .pixelOutline()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, PixelScale.px(4))
            .padding(.top, PixelScale.px(3))

            // Results
            if isSearching {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: PixelTheme.text))
                PixelText("SEARCHING...", size: .small, color: PixelTheme.textSecondary)
                Spacer()
            } else if searchResults.isEmpty {
                Spacer()
                PixelText("NO CLUBS FOUND", size: .medium, color: PixelTheme.textSecondary)
                PixelText("TRY A DIFFERENT SEARCH", size: .small, color: PixelTheme.textSecondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: PixelScale.px(2)) {
                        ForEach(searchResults) { club in
                            PixelClubSearchCard(club: club) {
                                joinClub(club)
                            }
                        }
                    }
                    .padding(.horizontal, PixelScale.px(4))
                }
            }
        }
    }

    // MARK: - Actions

    private func joinWithCode() {
        guard let userID = player.appleUserID else {
            errorMessage = "You must be signed in to join a club."
            showError = true
            return
        }

        isJoining = true

        Task {
            do {
                guard let record = try await CloudKitService.shared.fetchClub(inviteCode: inviteCode) else {
                    await MainActor.run {
                        isJoining = false
                        errorMessage = CloudKitError.invalidInviteCode.localizedDescription
                        showError = true
                    }
                    return
                }

                try await CloudKitService.shared.joinClub(
                    clubRecord: record,
                    userID: userID,
                    displayName: player.effectiveDisplayName
                )

                await MainActor.run {
                    let ownerID = record["ownerUserID"] as? String ?? ""
                    let club = Club(
                        cloudKitRecordName: record.recordID.recordName,
                        name: record["name"] as? String ?? "",
                        description: record["description"] as? String ?? "",
                        inviteCode: record["inviteCode"] as? String ?? inviteCode,
                        isOwner: ownerID == userID,
                        memberCount: (record["memberCount"] as? Int ?? 0) + 1,
                        maxMembers: record["maxMembers"] as? Int ?? 50,
                        isPublic: (record["isPublic"] as? Int ?? 0) == 1
                    )

                    modelContext.insert(club)
                    player.clubs?.append(club)
                    try? modelContext.save()

                    isJoining = false
                    onJoined(club)
                }
            } catch let error as CloudKitError {
                await MainActor.run {
                    isJoining = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isJoining = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func searchClubs() {
        isSearching = true

        Task {
            do {
                let results = try await CloudKitService.shared.searchPublicClubs(query: searchQuery)

                await MainActor.run {
                    // Filter out clubs user is already a member of
                    let memberRecordNames = Set((player.clubs ?? []).map { $0.cloudKitRecordName })
                    searchResults = results.filter { !memberRecordNames.contains($0.recordName) }
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    isSearching = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func joinClub(_ club: ClubSearchResult) {
        guard let userID = player.appleUserID else {
            errorMessage = "You must be signed in to join a club."
            showError = true
            return
        }

        isJoining = true

        Task {
            do {
                guard let record = try await CloudKitService.shared.fetchClubByRecordName(club.recordName) else {
                    await MainActor.run {
                        isJoining = false
                        errorMessage = CloudKitError.clubNotFound.localizedDescription
                        showError = true
                    }
                    return
                }

                try await CloudKitService.shared.joinClub(
                    clubRecord: record,
                    userID: userID,
                    displayName: player.effectiveDisplayName
                )

                await MainActor.run {
                    let newClub = Club(
                        cloudKitRecordName: club.recordName,
                        name: club.name,
                        description: club.description,
                        inviteCode: "",
                        isOwner: false,
                        memberCount: club.memberCount + 1,
                        maxMembers: club.maxMembers,
                        isPublic: club.isPublic
                    )

                    modelContext.insert(newClub)
                    player.clubs?.append(newClub)
                    try? modelContext.save()

                    isJoining = false
                    onJoined(newClub)
                }
            } catch let error as CloudKitError {
                await MainActor.run {
                    isJoining = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isJoining = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    JoinClubSheet(player: Player(name: "Test")) { _ in }
        .modelContainer(for: [Player.self, Club.self], inMemory: true)
}
