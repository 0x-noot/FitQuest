import SwiftUI
import SwiftData

struct TreatSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var pet: Pet
    @Bindable var player: Player

    @State private var selectedTreat: PetTreat?
    @State private var showSuccessAnimation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    PetCompanionView(pet: pet, size: 80)

                    VStack(spacing: 4) {
                        Text("Feed \(pet.name)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Theme.textPrimary)

                        Text("Current happiness: \(Int(pet.happiness))%")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding(.top, 20)

                // Essence balance
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.warning)

                    Text("Your Essence:")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Spacer()

                    Text("\(player.essenceCurrency)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.warning)
                }
                .padding(16)
                .background(Theme.elevated)
                .cornerRadius(12)

                // Treat options
                VStack(spacing: 12) {
                    ForEach(PetTreat.allCases, id: \.self) { treat in
                        TreatOptionButton(
                            treat: treat,
                            canAfford: player.essenceCurrency >= treat.essenceCost,
                            isSelected: selectedTreat == treat,
                            onTap: {
                                selectedTreat = treat
                            }
                        )
                    }
                }

                Spacer()

                // Feed button
                if let treat = selectedTreat {
                    PrimaryButton("Feed \(treat.displayName)", icon: "heart.fill") {
                        feedTreat(treat)
                    }
                    .disabled(player.essenceCurrency < treat.essenceCost)
                    .opacity(player.essenceCurrency < treat.essenceCost ? 0.5 : 1.0)
                }
            }
            .padding(20)
            .padding(.bottom, 20)
            .background(Theme.background)
            .navigationTitle("Treats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.cardBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
            .overlay(
                Group {
                    if showSuccessAnimation {
                        successOverlay
                    }
                }
            )
        }
    }

    private var successOverlay: some View {
        ZStack {
            Theme.background.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.warning)
                    .scaleEffect(showSuccessAnimation ? 1.2 : 0.5)
                    .opacity(showSuccessAnimation ? 1.0 : 0.0)

                Text("+\(Int(selectedTreat?.happinessBoost ?? 0))% Happiness!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .transition(.opacity)
    }

    private func feedTreat(_ treat: PetTreat) {
        let success = PetManager.feedTreat(pet: pet, treat: treat, player: player)

        guard success else { return }

        // Save context
        try? modelContext.save()

        // Show success animation
        withAnimation(.spring(duration: 0.4)) {
            showSuccessAnimation = true
        }

        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

struct TreatOptionButton: View {
    let treat: PetTreat
    let canAfford: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(canAfford ? Theme.warning.opacity(0.2) : Theme.elevated)
                        .frame(width: 60, height: 60)

                    Image(systemName: treat.iconName)
                        .font(.system(size: iconSize))
                        .foregroundColor(canAfford ? Theme.warning : Theme.textMuted)
                }

                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(treat.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text(treat.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.success)

                        Text("+\(Int(treat.happinessBoost))% happiness")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.success)
                    }
                }

                Spacer()

                // Cost
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(treat.essenceCost)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(canAfford ? Theme.warning : Theme.textMuted)

                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(canAfford ? Theme.warning : Theme.textMuted)
                    }

                    if !canAfford {
                        Text("Not enough")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Theme.textMuted)
                    }
                }

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.primary)
                }
            }
            .padding(16)
            .background(isSelected ? Theme.primary.opacity(0.1) : Theme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.primary : (canAfford ? Color.clear : Theme.textMuted.opacity(0.3)), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!canAfford)
    }

    private var iconSize: CGFloat {
        switch treat {
        case .small: return 20
        case .medium: return 24
        case .large: return 28
        }
    }
}

#Preview {
    TreatSelectionSheet(
        pet: {
            let pet = Pet(name: "Fluffy", species: .fox)
            pet.happiness = 65
            return pet
        }(),
        player: {
            let p = Player(name: "Test")
            p.essenceCurrency = 50
            return p
        }()
    )
    .preferredColorScheme(.dark)
}
