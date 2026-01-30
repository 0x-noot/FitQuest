import SwiftUI

struct OnboardingCompleteStep: View {
    let playerName: String
    let petSpecies: PetSpecies?
    let petName: String
    let weeklyGoal: Int
    let onComplete: () -> Void

    @State private var animateIn = false

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            Spacer()

            // Pet display with pixel sprite
            if let species = petSpecies {
                VStack(spacing: PixelScale.px(2)) {
                    PixelSpriteView(
                        sprite: PetSpriteLibrary.sprite(for: species, stage: .baby),
                        pixelSize: 5,
                        palette: PixelTheme.PetPalette.palette(for: species)
                    )
                    .frame(width: 80, height: 80)
                    .padding(PixelScale.px(3))
                    .background(PixelTheme.cardBackground)
                    .pixelBorder(thickness: 2)
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
                }
            }

            // Title
            VStack(spacing: PixelScale.px(2)) {
                PixelText("JOURNEY BEGINS!", size: .xlarge)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                if let species = petSpecies {
                    let displayPetName = petName.isEmpty ? species.displayName : petName
                    PixelText("\(displayPetName.uppercased()) IS READY!", size: .medium, color: PixelTheme.textSecondary)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                }
            }

            // Summary card
            PixelPanel(title: "SUMMARY") {
                VStack(spacing: PixelScale.px(2)) {
                    if let species = petSpecies {
                        HStack {
                            PixelIconView(icon: .paw, size: 12)
                            PixelText("YOUR PET", size: .small, color: PixelTheme.textSecondary)
                            Spacer()
                            PixelText(petName.isEmpty ? species.displayName.uppercased() : petName.uppercased(), size: .small)
                        }

                        Rectangle()
                            .fill(PixelTheme.border)
                            .frame(height: PixelScale.px(1))
                    }

                    HStack {
                        PixelIconView(icon: .star, size: 12)
                        PixelText("WEEKLY GOAL", size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                        PixelText("\(weeklyGoal) WORKOUTS", size: .small)
                    }

                    Rectangle()
                        .fill(PixelTheme.border)
                        .frame(height: PixelScale.px(1))

                    HStack {
                        PixelIconView(icon: .flame, size: 12)
                        PixelText("STREAK", size: .small, color: PixelTheme.textSecondary)
                        Spacer()
                        PixelText("0 WEEKS", size: .small)
                    }
                }
            }
            .padding(.horizontal, PixelScale.px(4))
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 30)

            Spacer()

            // Start button
            PixelButton("LET'S GO! >", style: .primary) {
                onComplete()
            }
            .padding(.horizontal, PixelScale.px(4))
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 20)
        }
        .padding(.vertical, PixelScale.px(4))
        .onAppear {
            withAnimation(.spring(duration: 0.8)) {
                animateIn = true
            }
        }
    }
}

#Preview {
    OnboardingCompleteStep(
        playerName: "John",
        petSpecies: .dragon,
        petName: "Ember",
        weeklyGoal: 4
    ) {}
    .background(PixelTheme.background)
}
