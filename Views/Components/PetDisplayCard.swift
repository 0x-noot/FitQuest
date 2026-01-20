import SwiftUI

struct PetDisplayCard: View {
    @Bindable var pet: Pet
    let player: Player
    let onTap: () -> Void
    let onFeedTreat: () -> Void
    let onLevelUp: () -> Void

    var canLevelUp: Bool {
        PetManager.canLevelUp(pet: pet, player: player)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Pet icon with mood
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: pet.species.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(pet.isAway ? Theme.textMuted : pet.mood.color)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(pet.isAway ? Theme.elevated : pet.mood.color.opacity(0.2))
                            )

                        if !pet.isAway {
                            Text(pet.mood.emoji)
                                .font(.system(size: 20))
                                .offset(x: 4, y: 4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(pet.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)

                            if !pet.isAway {
                                Text("Lv\(pet.level)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Theme.primary.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }

                        if pet.isAway {
                            Text("Away from home...")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textMuted)
                        } else {
                            Text(pet.mood.description)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(pet.mood.color)

                            // Happiness bar
                            HappinessBar(happiness: pet.happiness, color: pet.mood.color)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textMuted)
                }

                // Quick action buttons (only if pet is active)
                if !pet.isAway {
                    HStack(spacing: 8) {
                        // Feed treat button
                        Button {
                            onFeedTreat()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12))
                                Text("Feed")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(player.essenceCurrency >= 10 ? .white : Theme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(player.essenceCurrency >= 10 ? Theme.primary : Theme.elevated)
                            .cornerRadius(8)
                        }
                        .disabled(player.essenceCurrency < 10)
                        .buttonStyle(.plain)

                        // Level up button
                        Button {
                            onLevelUp()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 12))
                                Text("Level \(pet.levelUpCost) ✨")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(canLevelUp ? .white : Theme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(canLevelUp ? Theme.success : Theme.elevated)
                            .cornerRadius(8)
                        }
                        .disabled(!canLevelUp)
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct HappinessBar: View {
    let happiness: Double
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.elevated)
                    .frame(height: 6)

                // Fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(happiness / 100.0), height: 6)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Active happy pet
        PetDisplayCard(
            pet: {
                let pet = Pet(name: "Fluffy", species: .fox)
                pet.happiness = 95
                pet.level = 5
                return pet
            }(),
            player: {
                let player = Player()
                player.essenceCurrency = 200
                return player
            }(),
            onTap: {},
            onFeedTreat: {},
            onLevelUp: {}
        )

        // Sad pet
        PetDisplayCard(
            pet: {
                let pet = Pet(name: "Spike", species: .dragon)
                pet.happiness = 25
                pet.level = 1
                return pet
            }(),
            player: {
                let player = Player()
                player.essenceCurrency = 50
                return player
            }(),
            onTap: {},
            onFeedTreat: {},
            onLevelUp: {}
        )

        // Away pet
        PetDisplayCard(
            pet: {
                let pet = Pet(name: "Shelly", species: .turtle)
                pet.isAway = true
                return pet
            }(),
            player: Player(),
            onTap: {},
            onFeedTreat: {},
            onLevelUp: {}
        )
    }
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
