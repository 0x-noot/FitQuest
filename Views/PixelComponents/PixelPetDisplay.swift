import SwiftUI

// MARK: - Pixel Pet Display

/// Main pet display component for the home screen
struct PixelPetDisplay: View {
    let pet: Pet
    let context: SpriteContext
    let isAnimating: Bool
    let onTap: (() -> Void)?
    let onLongPress: (() -> Void)?

    @State private var bounceOffset: CGFloat = 0

    init(
        pet: Pet,
        context: SpriteContext = .home,
        isAnimating: Bool = true,
        onTap: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil
    ) {
        self.pet = pet
        self.context = context
        self.isAnimating = isAnimating
        self.onTap = onTap
        self.onLongPress = onLongPress
    }

    private var pixelSize: CGFloat {
        PetSpriteLibrary.pixelSize(for: context, stage: pet.evolutionStage)
    }

    private var animation: SpriteAnimation {
        PetSpriteLibrary.animation(
            for: pet.species,
            stage: pet.evolutionStage,
            mood: pet.isAway ? .miserable : pet.mood
        )
    }

    var body: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Pet sprite with animation
            ZStack {
                // Background panel
                Rectangle()
                    .fill(PixelTheme.cardBackground)
                    .frame(
                        width: 16 * pixelSize + PixelScale.px(4),
                        height: 16 * pixelSize + PixelScale.px(4)
                    )
                    .pixelOutline()

                // Animated sprite
                AnimatedSpriteView(
                    animation: animation,
                    pixelSize: pixelSize,
                    isAnimating: isAnimating && !pet.isAway
                )
                .opacity(pet.isAway ? 0.5 : 1.0)
                .offset(y: bounceOffset)
            }
            .contentShape(Rectangle())
            .highPriorityGesture(
                TapGesture()
                    .onEnded {
                        // Bounce effect
                        withAnimation(.easeOut(duration: 0.1)) {
                            bounceOffset = -PixelScale.px(2)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeIn(duration: 0.1)) {
                                bounceOffset = 0
                            }
                        }
                        onTap?()
                    }
            )
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        onLongPress?()
                    }
            )

            // Pet info bar
            if context == .home || context == .detail {
                PixelPetInfoBar(pet: pet)
            }
        }
    }
}

// MARK: - Pixel Pet Info Bar

/// Shows pet name, level, and mood
struct PixelPetInfoBar: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: PixelScale.px(1)) {
            // Name
            PixelText(pet.name, size: .medium)

            // Level and mood
            HStack(spacing: PixelScale.px(2)) {
                PixelText("LV.\(pet.currentLevel)", size: .small, color: PixelTheme.textSecondary)
                PixelText(pet.mood.emoji, size: .small, uppercase: false)
            }
        }
        .padding(.horizontal, PixelScale.px(3))
        .padding(.vertical, PixelScale.px(1))
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }
}

// MARK: - Compact Pet Card

/// Smaller pet display for lists and cards
struct PixelPetCard: View {
    let pet: Pet

    var body: some View {
        HStack(spacing: PixelScale.px(2)) {
            // Small sprite
            PixelPetDisplay(
                pet: pet,
                context: .card,
                isAnimating: true,
                onTap: nil
            )

            // Info
            VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                PixelText(pet.name, size: .medium)
                PixelText("LV.\(pet.currentLevel) \(pet.species.displayName)", size: .small, color: PixelTheme.textSecondary)

                // Happiness bar
                PixelProgressBar(
                    progress: pet.happiness / 100.0,
                    segments: 8,
                    height: PixelScale.px(2)
                )
            }
        }
        .padding(PixelScale.px(2))
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }
}

// MARK: - Pet Play Session View

/// Overlay shown during pet play interactions
struct PixelPlaySessionView: View {
    let sessionsRemaining: Int
    @Binding var isVisible: Bool

    var body: some View {
        VStack(spacing: PixelScale.px(2)) {
            PixelIconView(icon: .heartFill, size: 24)

            PixelText("PLAY COMPLETE!", size: .medium)

            PixelText("\(sessionsRemaining) LEFT TODAY", size: .small, color: PixelTheme.textSecondary)
        }
        .padding(PixelScale.px(3))
        .background(PixelTheme.cardBackground)
        .pixelBorder(thickness: 2)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isVisible = false
            }
        }
    }
}

// MARK: - Pixel Speech Bubble

/// Speech bubble for pet dialogue
struct PixelSpeechBubble: View {
    let text: String
    @Binding var isVisible: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Bubble content
            PixelText(text, size: .small)
                .multilineTextAlignment(.center)
                .padding(PixelScale.px(2))
                .background(PixelTheme.cardBackground)
                .pixelOutline()

            // Pointer triangle (using pixels)
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(PixelTheme.border)
                        .frame(width: PixelScale.px(2), height: PixelScale.px(1))
                    Rectangle()
                        .fill(PixelTheme.border)
                        .frame(width: PixelScale.px(1), height: PixelScale.px(1))
                }
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                isVisible = false
            }
        }
        .onTapGesture {
            isVisible = false
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Create a test pet
        let testPet: Pet = {
            let p = Pet(name: "Ember", species: .dragon)
            p.totalXP = 500
            p.happiness = 85
            return p
        }()

        PixelPetDisplay(
            pet: testPet,
            context: .home,
            isAnimating: true
        )

        PixelPetCard(pet: testPet)

        PixelSpeechBubble(text: "HELLO FRIEND!", isVisible: .constant(true))
    }
    .padding(20)
    .background(PixelTheme.background)
}
