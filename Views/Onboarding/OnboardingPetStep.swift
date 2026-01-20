import SwiftUI

struct OnboardingPetStep: View {
    @Binding var selectedSpecies: PetSpecies?
    @Binding var petName: String
    let onContinue: () -> Void

    @State private var showNameInput = false
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Choose Your Companion")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Your pet will motivate you and earn bonuses!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            Spacer()

            if !showNameInput {
                // Species selection
                VStack(spacing: 12) {
                    ForEach(PetSpecies.allCases, id: \.self) { species in
                        PetSelectionCard(
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
            } else {
                // Name input
                if let species = selectedSpecies {
                    VStack(spacing: 20) {
                        // Show selected pet
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primary.opacity(0.2))
                                    .frame(width: 120, height: 120)

                                Image(systemName: species.iconName)
                                    .font(.system(size: 60))
                                    .foregroundColor(Theme.primary)
                            }

                            Text("Your \(species.displayName)")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)

                            Text(species.description)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 20)

                        // Name input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name your pet")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.textSecondary)

                            TextField("Enter name", text: $petName)
                                .font(.system(size: 18))
                                .padding(16)
                                .background(Theme.cardBackground)
                                .cornerRadius(12)
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
                            Text("Choose Different Pet")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }

            Spacer()

            // Continue button
            if showNameInput && !petName.trimmingCharacters(in: .whitespaces).isEmpty {
                OnboardingProgressBar(currentStep: 0, totalSteps: 1)
                    .padding(.bottom, 8)

                PrimaryButton("Continue", icon: "arrow.right") {
                    onContinue()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

struct PetSelectionCard: View {
    let species: PetSpecies
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Pet icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Theme.primary.opacity(0.2) : Theme.elevated)
                        .frame(width: 60, height: 60)

                    Image(systemName: species.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? Theme.primary : Theme.textSecondary)
                }

                // Pet info
                VStack(alignment: .leading, spacing: 4) {
                    Text(species.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text(species.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

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
                    .stroke(isSelected ? Theme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingPetStep(
        selectedSpecies: .constant(nil),
        petName: .constant(""),
        onContinue: {}
    )
    .preferredColorScheme(.dark)
    .background(Theme.background)
}
