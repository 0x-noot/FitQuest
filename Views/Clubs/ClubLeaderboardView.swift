import SwiftUI
import SwiftData

struct ClubLeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player
    @Bindable var club: Club

    @State private var entries: [LeaderboardEntry] = []
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
                Button(action: loadLeaderboard) {
                    PixelIconView(icon: .bolt, size: 20, color: PixelTheme.text)
                }
            }
            .padding(.horizontal, PixelScale.px(4))
            .padding(.top, PixelScale.px(2))

            // Title Header
            VStack(spacing: PixelScale.px(2)) {
                PixelIconView(icon: .trophy, size: 48, color: Color(hex: "FFD700"))
                PixelText("WEEKLY LEADERBOARD", size: .large)
                PixelText(club.name.uppercased(), size: .small, color: PixelTheme.textSecondary)
            }
            .padding(PixelScale.px(4))

            // Leaderboard
            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: PixelTheme.text))
                PixelText("LOADING...", size: .small, color: PixelTheme.textSecondary)
                Spacer()
            } else if entries.isEmpty {
                Spacer()
                VStack(spacing: PixelScale.px(2)) {
                    PixelText("NO RANKINGS YET", size: .medium, color: PixelTheme.textSecondary)
                    PixelText("COMPLETE WORKOUTS TO", size: .small, color: PixelTheme.textSecondary)
                    PixelText("CLIMB THE RANKS!", size: .small, color: PixelTheme.textSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: PixelScale.px(1)) {
                        // Top 3 podium
                        if entries.count >= 3 {
                            podiumView
                        }

                        // Full list
                        ForEach(entries) { entry in
                            PixelLeaderboardRow(entry: entry)
                        }
                    }
                    .padding(.horizontal, PixelScale.px(4))
                }
            }

            // Week info
            VStack(spacing: PixelScale.px(1)) {
                PixelText("RESETS EVERY MONDAY", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(PixelScale.px(3))
        }
        .background(PixelTheme.background)
        .presentationBackground(PixelTheme.background)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadLeaderboard()
        }
    }

    // MARK: - Podium View

    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: PixelScale.px(2)) {
            // 2nd place
            if entries.count > 1 {
                podiumPosition(entry: entries[1], height: 60, color: Color(hex: "C0C0C0"))
            }

            // 1st place
            if entries.count > 0 {
                podiumPosition(entry: entries[0], height: 80, color: Color(hex: "FFD700"))
            }

            // 3rd place
            if entries.count > 2 {
                podiumPosition(entry: entries[2], height: 40, color: Color(hex: "CD7F32"))
            }
        }
        .padding(.vertical, PixelScale.px(4))
    }

    private func podiumPosition(entry: LeaderboardEntry, height: CGFloat, color: Color) -> some View {
        VStack(spacing: PixelScale.px(1)) {
            PixelText(entry.displayName.uppercased().prefix(8) + (entry.displayName.count > 8 ? ".." : ""), size: .small)
            PixelText("\(entry.weeklyXP) XP", size: .small, color: Color(hex: "4ECDC4"))

            Rectangle()
                .fill(color)
                .frame(width: PixelScale.px(16), height: height)
                .pixelOutline()

            PixelText(ClubManager.formatRank(entry.rank), size: .small, color: color)
        }
    }

    // MARK: - Actions

    private func loadLeaderboard() {
        guard let userID = player.appleUserID else { return }

        isLoading = true

        Task {
            do {
                let fetchedEntries = try await CloudKitService.shared.fetchLeaderboard(
                    clubRecordName: club.cloudKitRecordName,
                    currentUserID: userID
                )

                await MainActor.run {
                    entries = fetchedEntries
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
}

#Preview {
    ClubLeaderboardView(
        player: Player(name: "Test"),
        club: Club(
            cloudKitRecordName: "test",
            name: "Fitness Warriors",
            description: "",
            inviteCode: "ABC123",
            isOwner: false
        )
    )
    .modelContainer(for: [Player.self, Club.self], inMemory: true)
}
