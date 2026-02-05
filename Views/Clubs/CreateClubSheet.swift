import SwiftUI
import SwiftData
import CloudKit

struct CreateClubSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var player: Player

    let onCreated: (Club) -> Void

    @State private var clubName = ""
    @State private var clubDescription = ""
    @State private var isPublic = false
    @State private var isCreating = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var isValid: Bool {
        ClubManager.validateClubName(clubName) &&
        ClubManager.validateDescription(clubDescription)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: PixelScale.px(4)) {
                // Header
                VStack(spacing: PixelScale.px(2)) {
                    PixelIconView(icon: .group, size: 48, color: PixelTheme.gbLightest)
                    PixelText("CREATE CLUB", size: .xlarge)
                }
                .padding(.top, PixelScale.px(4))

                // Form
                VStack(spacing: PixelScale.px(3)) {
                    // Name field
                    VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                        PixelText("CLUB NAME", size: .small, color: PixelTheme.textSecondary)

                        TextField("", text: $clubName)
                            .textFieldStyle(.plain)
                            .font(.custom("Menlo", size: 14))
                            .foregroundColor(PixelTheme.text)
                            .textInputAutocapitalization(.words)
                            .padding(PixelScale.px(2))
                            .background(PixelTheme.cardBackground)
                            .pixelOutline()

                        PixelText("\(clubName.count)/\(ClubManager.maxClubNameLength)", size: .small, color: PixelTheme.textSecondary)
                    }

                    // Description field
                    VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                        PixelText("DESCRIPTION (OPTIONAL)", size: .small, color: PixelTheme.textSecondary)

                        TextField("", text: $clubDescription, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.custom("Menlo", size: 14))
                            .foregroundColor(PixelTheme.text)
                            .lineLimit(3...5)
                            .padding(PixelScale.px(2))
                            .background(PixelTheme.cardBackground)
                            .pixelOutline()

                        PixelText("\(clubDescription.count)/\(ClubManager.maxDescriptionLength)", size: .small, color: PixelTheme.textSecondary)
                    }

                    // Public toggle
                    HStack {
                        VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                            PixelText("PUBLIC CLUB", size: .small)
                            PixelText("ANYONE CAN FIND & JOIN", size: .small, color: PixelTheme.textSecondary)
                        }

                        Spacer()

                        PixelToggle(label: "", isOn: $isPublic)
                    }
                    .padding(PixelScale.px(2))
                    .background(PixelTheme.cardBackground)
                    .pixelOutline()
                }
                .padding(.horizontal, PixelScale.px(4))

                Spacer()

                // Create button
                VStack(spacing: PixelScale.px(2)) {
                    if isCreating {
                        HStack(spacing: PixelScale.px(2)) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: PixelTheme.text))
                                .scaleEffect(0.8)
                            PixelText("CREATING...", size: .small, color: PixelTheme.textSecondary)
                        }
                    } else {
                        PixelButton("CREATE CLUB", style: .primary) {
                            createClub()
                        }
                        .disabled(!isValid)
                        .opacity(isValid ? 1 : 0.5)
                    }
                }
                .padding(PixelScale.px(4))
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

    private func createClub() {
        guard let userID = player.appleUserID else {
            errorMessage = "You must be signed in to create a club."
            showError = true
            return
        }

        guard isValid else { return }

        isCreating = true

        Task {
            do {
                let record = try await CloudKitService.shared.createClub(
                    name: clubName.trimmingCharacters(in: .whitespaces),
                    description: clubDescription.trimmingCharacters(in: .whitespaces),
                    isPublic: isPublic,
                    ownerID: userID,
                    ownerDisplayName: player.effectiveDisplayName
                )

                await MainActor.run {
                    let club = Club(
                        cloudKitRecordName: record.recordID.recordName,
                        name: record["name"] as? String ?? clubName,
                        description: record["description"] as? String ?? clubDescription,
                        inviteCode: record["inviteCode"] as? String ?? "",
                        isOwner: true,
                        memberCount: 1,
                        maxMembers: ClubManager.maxMembersPerClub,
                        isPublic: isPublic
                    )

                    modelContext.insert(club)
                    player.clubs?.append(club)
                    try? modelContext.save()

                    isCreating = false
                    onCreated(club)
                }
            } catch let error as CloudKitError {
                await MainActor.run {
                    isCreating = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    CreateClubSheet(player: Player(name: "Test")) { _ in }
        .modelContainer(for: [Player.self, Club.self], inMemory: true)
}
