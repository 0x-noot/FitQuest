import SwiftUI

struct PetCompanionView: View {
    let pet: Pet
    let size: CGFloat
    @State private var breatheAnimation = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Pet icon
            ZStack {
                // Background circle
                Circle()
                    .fill(pet.mood.color.opacity(0.2))
                    .frame(width: size * 0.8, height: size * 0.8)

                // Pet icon
                Image(systemName: pet.species.iconName)
                    .font(.system(size: size * 0.4))
                    .foregroundColor(pet.isAway ? Theme.textMuted.opacity(0.5) : pet.mood.color)
            }
            .scaleEffect(breatheAnimation ? 1.02 : 1.0)
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: breatheAnimation
            )
            .opacity(pet.isAway ? 0.5 : 1.0)

            // Level badge
            if !pet.isAway {
                ZStack {
                    Circle()
                        .fill(Theme.primary)
                        .frame(width: size * 0.25, height: size * 0.25)

                    Text("\(pet.level)")
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
        .onAppear {
            breatheAnimation = true
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        // Active pet
        PetCompanionView(
            pet: {
                let pet = Pet(name: "Fluffy", species: .fox)
                pet.happiness = 95
                pet.level = 5
                return pet
            }(),
            size: 80
        )

        // Sad pet
        PetCompanionView(
            pet: {
                let pet = Pet(name: "Spike", species: .dragon)
                pet.happiness = 25
                pet.level = 1
                return pet
            }(),
            size: 80
        )

        // Away pet
        PetCompanionView(
            pet: {
                let pet = Pet(name: "Shelly", species: .turtle)
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
