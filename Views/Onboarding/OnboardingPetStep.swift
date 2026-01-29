import SwiftUI

struct OnboardingPetStep: View {
    @Binding var selectedSpecies: PetSpecies?
    @Binding var petName: String
    let onContinue: () -> Void

    @State private var showNameInput = false
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(spacing: PixelScale.px(3)) {
            // Header
            VStack(spacing: PixelScale.px(1)) {
                PixelText("CHOOSE YOUR", size: .medium, color: PixelTheme.textSecondary)
                PixelText("COMPANION", size: .xlarge)

                PixelText("YOUR PET GROWS AS YOU TRAIN!", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(.top, PixelScale.px(2))

            if !showNameInput {
                // Species selection
                ScrollView {
                    VStack(spacing: PixelScale.px(2)) {
                        ForEach(PetSpecies.allCases, id: \.self) { species in
                            PixelPetSelectionCard(
                                species: species,
                                isSelected: selectedSpecies == species,
                                onTap: {
                                    selectedSpecies = species
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showNameInput = true
                                    }
                                    // Auto-focus name field after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        isNameFieldFocused = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical, PixelScale.px(2))
                }
            } else {
                // Name input
                if let species = selectedSpecies {
                    Spacer()

                    VStack(spacing: PixelScale.px(4)) {
                        // Show selected pet with pixel sprite
                        PixelPanel(title: species.displayName.uppercased()) {
                            VStack(spacing: PixelScale.px(2)) {
                                // Pet sprite preview
                                PixelSpriteView(
                                    sprite: PetSpriteLibrary.sprite(for: species, stage: .baby),
                                    pixelSize: 4
                                )
                                .frame(width: 64, height: 64)

                                PixelText(species.personality.uppercased(), size: .small, color: PixelTheme.textSecondary)

                                PixelText(species.description.uppercased(), size: .small, color: PixelTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        // Name input
                        PixelPanel(title: "NAME YOUR PET") {
                            TextField("ENTER NAME", text: $petName)
                                .font(.custom("Menlo-Bold", size: PixelFontSize.medium.pointSize))
                                .foregroundColor(PixelTheme.text)
                                .textInputAutocapitalization(.characters)
                                .focused($isNameFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    if !petName.isEmpty {
                                        onContinue()
                                    }
                                }
                        }

                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showNameInput = false
                                petName = ""
                            }
                        } label: {
                            PixelText("< CHOOSE DIFFERENT", size: .small, color: PixelTheme.textSecondary)
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                    .padding(.horizontal, PixelScale.px(4))

                    Spacer()
                }
            }

            // Continue button
            if showNameInput && !petName.trimmingCharacters(in: .whitespaces).isEmpty {
                PixelButton("CONTINUE >", style: .primary) {
                    onContinue()
                }
                .padding(.horizontal, PixelScale.px(4))
            }
        }
        .padding(.vertical, PixelScale.px(4))
    }
}

// MARK: - Pixel Pet Selection Card

struct PixelPetSelectionCard: View {
    let species: PetSpecies
    let isSelected: Bool
    let onTap: () -> Void

    private var speciesIcon: PixelIcon {
        switch species {
        case .plant: return .leaf
        case .cat: return .cat
        case .dog: return .dog
        case .wolf: return .dog
        case .dragon: return .dragon
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PixelScale.px(2)) {
                // Pet sprite preview
                PixelSpriteView(
                    sprite: PetSpriteLibrary.sprite(for: species, stage: .baby),
                    pixelSize: 2
                )
                .frame(width: 32, height: 32)

                // Pet info
                VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                    HStack(spacing: PixelScale.px(1)) {
                        PixelText(species.displayName.uppercased(), size: .small)

                        PixelText(species.personality.uppercased(), size: .small, color: PixelTheme.textSecondary)
                    }

                    PixelText(species.description.uppercased(), size: .small, color: PixelTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    PixelIconView(icon: .check, size: 16)
                }
            }
            .padding(PixelScale.px(2))
            .background(isSelected ? PixelTheme.gbDark.opacity(0.3) : PixelTheme.cardBackground)
            .pixelOutline()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, PixelScale.px(4))
    }
}

#Preview {
    OnboardingPetStep(
        selectedSpecies: .constant(nil),
        petName: .constant(""),
        onContinue: {}
    )
    .background(PixelTheme.background)
}
