import SwiftUI

struct PetDisplayCard: View {
    @Bindable var pet: Pet
    let player: Player
    let onTap: () -> Void
    let onFeedTreat: () -> Void

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
                                HStack(spacing: 2) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 10))
                                    Text("Lv\(pet.currentLevel)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                }
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

                // Quick action button (only if pet is active)
                if !pet.isAway {
                    HStack(spacing: 8) {
                        // Feed treat button
                        Button {
                            onFeedTreat()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12))
                                Text("Feed Treat")
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

                        // XP Progress indicator
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(Int(pet.xpProgress * 100))% to Lv\(pet.currentLevel + 1)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)

                            // Mini progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Theme.elevated)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Theme.primary)
                                        .frame(width: geo.size.width * pet.xpProgress)
                                }
                            }
                            .frame(height: 4)
                        }
                        .frame(maxWidth: .infinity)
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
                let pet = Pet(name: "Fluffy", species: .cat)
                pet.happiness = 95
                pet.totalXP = 500
                return pet
            }(),
            player: {
                let player = Player()
                player.essenceCurrency = 200
                return player
            }(),
            onTap: {},
            onFeedTreat: {}
        )

        // Sad pet
        PetDisplayCard(
            pet: {
                let pet = Pet(name: "Spike", species: .dragon)
                pet.happiness = 25
                pet.totalXP = 100
                return pet
            }(),
            player: {
                let player = Player()
                player.essenceCurrency = 50
                return player
            }(),
            onTap: {},
            onFeedTreat: {}
        )

        // Away pet
        PetDisplayCard(
            pet: {
                let pet = Pet(name: "Shelly", species: .plant)
                pet.isAway = true
                return pet
            }(),
            player: Player(),
            onTap: {},
            onFeedTreat: {}
        )
    }
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
