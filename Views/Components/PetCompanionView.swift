import SwiftUI

struct PetCompanionView: View {
    let pet: Pet
    let size: CGFloat
    @State private var breatheAnimation = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Pet icon with mood-based animations
            ZStack {
                // Evolution aura (for teen and adult stages)
                if pet.evolutionStage.glowIntensity > 0 && !pet.isAway {
                    Circle()
                        .fill(pet.evolutionStage.auraColor)
                        .frame(width: size * 0.9, height: size * 0.9)
                        .blur(radius: 10)
                }

                // Background circle - with accessory background if equipped
                if let bgAccessory = pet.equippedBackground, let gradient = bgAccessory.backgroundGradient {
                    Circle()
                        .fill(gradient)
                        .frame(width: size * 0.8, height: size * 0.8)
                } else {
                    Circle()
                        .fill(pet.mood.color.opacity(0.2))
                        .frame(width: size * 0.8, height: size * 0.8)
                }

                // Pet icon with mood animations - uses evolution-based icon and scale
                Image(systemName: pet.evolutionIconName)
                    .font(.system(size: size * 0.4 * pet.evolutionStage.iconScale))
                    .foregroundColor(pet.isAway ? Theme.textMuted.opacity(0.5) : pet.mood.color)
                    .animatedPet(mood: pet.mood, isAway: pet.isAway)
                    .moodScale(mood: pet.mood, isAway: pet.isAway)

                // Hat accessory
                if let hat = pet.equippedHat, !pet.isAway {
                    Image(systemName: hat.iconName)
                        .font(.system(size: size * 0.15))
                        .foregroundColor(hat.rarity.color)
                        .offset(y: -size * 0.28)
                }

                // Sparkle effect for ecstatic mood OR equipped sparkle effect
                if (pet.mood == .ecstatic || pet.equippedEffect?.id == "effect_sparkle") && !pet.isAway {
                    SparkleEffect(isActive: true)
                        .frame(width: size, height: size)
                }

                // Heart effect accessory
                if pet.equippedEffect?.id == "effect_hearts" && !pet.isAway {
                    SparkleEffect(isActive: true)
                        .frame(width: size, height: size)
                }

                // Fire aura effect accessory
                if pet.equippedEffect?.id == "effect_fire" && !pet.isAway {
                    Circle()
                        .stroke(Color.orange.opacity(0.4), lineWidth: 3)
                        .frame(width: size * 0.85, height: size * 0.85)
                        .blur(radius: 3)
                }

                // Lightning aura effect accessory
                if pet.equippedEffect?.id == "effect_lightning" && !pet.isAway {
                    Circle()
                        .stroke(Color.yellow.opacity(0.5), lineWidth: 3)
                        .frame(width: size * 0.85, height: size * 0.85)
                        .blur(radius: 2)
                }

                // Tear drop effect for unhappy moods
                if !pet.isAway {
                    TearDropEffect(mood: pet.mood, size: size * 0.8)
                }
            }

            // Level badge with evolution-based color
            if !pet.isAway {
                ZStack {
                    Circle()
                        .fill(pet.evolutionStage.badgeColor)
                        .frame(width: size * 0.25, height: size * 0.25)

                    Text("\(pet.currentLevel)")
                        .font(.system(size: size * 0.12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .offset(x: size * 0.05, y: size * 0.05)
            }

            // Mood emoji overlay
            if !pet.isAway {
                Text(pet.mood.emoji)
                    .font(.system(size: size * 0.2))
                    .offset(x: -size * 0.25, y: -size * 0.25)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 30) {
        // Active pet
        PetCompanionView(
            pet: {
                let pet = Pet(name: "Fluffy", species: .cat)
                pet.happiness = 95
                pet.totalXP = 500
                return pet
            }(),
            size: 80
        )

        // Sad pet
        PetCompanionView(
            pet: {
                let pet = Pet(name: "Spike", species: .dragon)
                pet.happiness = 25
                pet.totalXP = 100
                return pet
            }(),
            size: 80
        )

        // Away pet
        PetCompanionView(
            pet: {
                let pet = Pet(name: "Shelly", species: .plant)
                pet.isAway = true
                return pet
            }(),
            size: 80
        )
    }
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
