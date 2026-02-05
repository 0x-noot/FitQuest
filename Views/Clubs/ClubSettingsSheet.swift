import SwiftUI
import SwiftData

struct ClubSettingsSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player
    @Bindable var club: Club

    let onLeave: () -> Void

    @State private var showLeaveConfirm = false
    @State private var showDeleteConfirm = false
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: PixelScale.px(4)) {
                // Header
                VStack(spacing: PixelScale.px(2)) {
                    PixelIconView(icon: .settings, size: 48, color: PixelTheme.gbLightest)
                    PixelText("CLUB SETTINGS", size: .large)
                    PixelText(club.name.uppercased(), size: .small, color: PixelTheme.textSecondary)
                }
                .padding(.top, PixelScale.px(4))

                // Club info
                VStack(spacing: PixelScale.px(2)) {
                    // Invite code
                    if !club.inviteCode.isEmpty {
                        HStack {
                            VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                                PixelText("INVITE CODE", size: .small, color: PixelTheme.textSecondary)
                                PixelText(club.inviteCode, size: .large, color: PixelTheme.gbLightest)
                            }

                            Spacer()

                            Button(action: copyInviteCode) {
                                PixelText("COPY", size: .small, color: Color(hex: "4ECDC4"))
                                    .padding(.horizontal, PixelScale.px(2))
                                    .padding(.vertical, PixelScale.px(1))
                                    .background(PixelTheme.gbDarkest)
                                    .pixelOutline()
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(PixelScale.px(3))
                        .background(PixelTheme.cardBackground)
                        .pixelOutline()
                    }

                    // Club stats
                    HStack(spacing: PixelScale.px(4)) {
                        VStack(spacing: PixelScale.px(1)) {
                            PixelText("\(club.memberCount)", size: .large)
                            PixelText("MEMBERS", size: .small, color: PixelTheme.textSecondary)
                        }

                        VStack(spacing: PixelScale.px(1)) {
                            PixelText(club.isPublic ? "YES" : "NO", size: .large)
                            PixelText("PUBLIC", size: .small, color: PixelTheme.textSecondary)
                        }

                        VStack(spacing: PixelScale.px(1)) {
                            PixelText(club.isOwner ? "YES" : "NO", size: .large)
                            PixelText("OWNER", size: .small, color: PixelTheme.textSecondary)
                        }
                    }
                    .padding(PixelScale.px(3))
                    .background(PixelTheme.cardBackground)
                    .pixelOutline()
                }
                .padding(.horizontal, PixelScale.px(4))

                Spacer()

                // Actions
                VStack(spacing: PixelScale.px(2)) {
                    if isProcessing {
                        HStack(spacing: PixelScale.px(2)) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: PixelTheme.text))
                                .scaleEffect(0.8)
                            PixelText("PROCESSING...", size: .small, color: PixelTheme.textSecondary)
                        }
                    } else if club.isOwner {
                        PixelButton("DELETE CLUB", icon: .minus, style: .danger) {
                            showDeleteConfirm = true
                        }
                        PixelText("THIS CANNOT BE UNDONE", size: .small, color: Color(hex: "FF5555"))
                    } else {
                        PixelButton("LEAVE CLUB", icon: .arrow, style: .danger) {
                            showLeaveConfirm = true
                        }
                    }
                }
                .padding(PixelScale.px(4))
            }
            .background(PixelTheme.background)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(PixelTheme.text)
                }
            }
        }
        .alert("Leave Club?", isPresented: $showLeaveConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                leaveClub()
            }
        } message: {
            Text("Are you sure you want to leave \(club.name)?")
        }
        .alert("Delete Club?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteClub()
            }
        } message: {
            Text("Are you sure you want to delete \(club.name)? This will remove all members and cannot be undone.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Actions

    private func copyInviteCode() {
        UIPasteboard.general.string = club.inviteCode
    }

    private func leaveClub() {
        guard let userID = player.appleUserID else {
            errorMessage = "You must be signed in."
            showError = true
            return
        }

        isProcessing = true

        Task {
            do {
                guard let record = try await CloudKitService.shared.fetchClubByRecordName(club.cloudKitRecordName) else {
                    await MainActor.run {
                        isProcessing = false
                        errorMessage = CloudKitError.clubNotFound.localizedDescription
                        showError = true
                    }
                    return
                }

                try await CloudKitService.shared.leaveClub(
                    clubRecord: record,
                    userID: userID,
                    displayName: player.effectiveDisplayName
                )

                await MainActor.run {
                    player.clubs?.removeAll { $0.id == club.id }
                    modelContext.delete(club)
                    try? modelContext.save()

                    isProcessing = false
                    dismiss()
                    onLeave()
                }
            } catch let error as CloudKitError {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func deleteClub() {
        guard let userID = player.appleUserID else {
            errorMessage = "You must be signed in."
            showError = true
            return
        }

        isProcessing = true

        Task {
            do {
                guard let record = try await CloudKitService.shared.fetchClubByRecordName(club.cloudKitRecordName) else {
                    await MainActor.run {
                        isProcessing = false
                        errorMessage = CloudKitError.clubNotFound.localizedDescription
                        showError = true
                    }
                    return
                }

                try await CloudKitService.shared.deleteClub(clubRecord: record, userID: userID)

                await MainActor.run {
                    player.clubs?.removeAll { $0.id == club.id }
                    modelContext.delete(club)
                    try? modelContext.save()

                    isProcessing = false
                    dismiss()
                    onLeave()
                }
            } catch let error as CloudKitError {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    ClubSettingsSheet(
        player: Player(name: "Test"),
        club: Club(
            cloudKitRecordName: "test",
            name: "Fitness Warriors",
            description: "A club for fitness enthusiasts",
            inviteCode: "ABC123",
            isOwner: true,
            memberCount: 15
        ),
        onLeave: {}
    )
    .modelContainer(for: [Player.self, Club.self], inMemory: true)
}
