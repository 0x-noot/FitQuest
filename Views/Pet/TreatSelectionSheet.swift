import SwiftUI
import SwiftData

struct TreatSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var pet: Pet
    @Bindable var player: Player
    var onTreatFed: (() -> Void)?

    @State private var selectedTreat: PetTreat?
    @State private var showSuccessAnimation = false

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    PixelText("CANCEL", size: .small)
                }

                Spacer()

                PixelText("TREATS", size: .medium)

                Spacer()

                // Spacer for balance
                PixelText("      ", size: .small)
            }
            .padding(.horizontal, PixelScale.px(2))
            .padding(.vertical, PixelScale.px(2))
            .background(PixelTheme.gbDark)

            Rectangle()
                .fill(PixelTheme.border)
                .frame(height: PixelScale.px(1))

            // Content
            ScrollView {
                VStack(spacing: PixelScale.px(3)) {
                    // Pet header
                    PixelPanel(title: "FEED \(pet.name.uppercased())") {
                        VStack(spacing: PixelScale.px(2)) {
                            PixelSpriteView(
                                sprite: PetSpriteLibrary.sprite(for: pet.species, stage: pet.evolutionStage),
                                pixelSize: 4
                            )
                            .frame(width: 64, height: 64)

                            PixelText("HAPPINESS: \(Int(pet.happiness))%", size: .small, color: PixelTheme.textSecondary)
                        }
                    }

                    // Essence balance
                    PixelPanel(title: "YOUR ESSENCE") {
                        HStack {
                            PixelIconView(icon: .sparkle, size: 16)
                            PixelText("BALANCE:", size: .small, color: PixelTheme.textSecondary)
                            Spacer()
                            PixelText("\(player.essenceCurrency)", size: .medium)
                        }
                    }

                    // Treat options
                    PixelPanel(title: "SELECT TREAT") {
                        VStack(spacing: PixelScale.px(2)) {
                            ForEach(PetTreat.allCases, id: \.self) { treat in
                                PixelTreatOptionButton(
                                    treat: treat,
                                    canAfford: player.essenceCurrency >= treat.essenceCost,
                                    isSelected: selectedTreat == treat,
                                    onTap: {
                                        selectedTreat = treat
                                    }
                                )
                            }
                        }
                    }

                    // Feed button
                    if let treat = selectedTreat {
                        PixelButton("FEED \(treat.displayName.uppercased())", style: .primary) {
                            feedTreat(treat)
                        }
                        .disabled(player.essenceCurrency < treat.essenceCost)
                        .opacity(player.essenceCurrency < treat.essenceCost ? 0.5 : 1.0)
                    }
                }
                .padding(PixelScale.px(2))
            }
        }
        .background(PixelTheme.background)
        .overlay(
            Group {
                if showSuccessAnimation {
                    successOverlay
                }
            }
        )
    }

    private var successOverlay: some View {
        ZStack {
            PixelTheme.background.opacity(0.9)
                .ignoresSafeArea()

            PixelPanel(title: "SUCCESS!") {
                VStack(spacing: PixelScale.px(2)) {
                    PixelIconView(icon: .heartFill, size: 48)

                    PixelText("+\(Int(selectedTreat?.happinessBoost ?? 0))%", size: .xlarge)
                    PixelText("HAPPINESS!", size: .medium, color: PixelTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(PixelScale.px(8))
        }
        .transition(.opacity)
    }

    private func feedTreat(_ treat: PetTreat) {
        let success = PetManager.feedTreat(pet: pet, treat: treat, player: player)

        guard success else { return }

        // Save context
        try? modelContext.save()

        // Notify callback
        onTreatFed?()

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

// MARK: - Pixel Treat Option Button

struct PixelTreatOptionButton: View {
    let treat: PetTreat
    let canAfford: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PixelScale.px(2)) {
                // Info
                VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                    PixelText(treat.displayName.uppercased(), size: .small)

                    HStack(spacing: PixelScale.px(1)) {
                        PixelIconView(icon: .heartFill, size: 10)
                        PixelText("+\(Int(treat.happinessBoost))%", size: .small, color: PixelTheme.textSecondary)
                    }
                }

                Spacer()

                // Cost
                HStack(spacing: PixelScale.px(1)) {
                    PixelText("\(treat.essenceCost)", size: .small, color: canAfford ? PixelTheme.text : PixelTheme.textSecondary)
                    PixelIconView(icon: .sparkle, size: 12)
                }

                // Selection indicator
                if isSelected {
                    PixelIconView(icon: .check, size: 16)
                }
            }
            .padding(PixelScale.px(2))
            .background(isSelected ? PixelTheme.gbDark.opacity(0.3) : PixelTheme.gbLight)
            .pixelOutline()
        }
        .buttonStyle(.plain)
        .disabled(!canAfford)
        .opacity(canAfford ? 1 : 0.5)
    }
}

#Preview {
    TreatSelectionSheet(
        pet: {
            let pet = Pet(name: "Fluffy", species: .cat)
            pet.happiness = 65
            return pet
        }(),
        player: {
            let p = Player(name: "Test")
            p.essenceCurrency = 50
            return p
        }()
    )
}
