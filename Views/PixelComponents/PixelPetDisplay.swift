import SwiftUI

// MARK: - Pixel Pet Display

/// Main pet display component for the home screen
struct PixelPetDisplay: View {
    let pet: Pet
    let context: SpriteContext
    let isAnimating: Bool
    let onTap: (() -> Void)?

    @State private var bounceOffset: CGFloat = 0
    @State private var haloFloat: CGFloat = 0
    @State private var animationYOffset: CGFloat = 0

    init(
        pet: Pet,
        context: SpriteContext = .home,
        isAnimating: Bool = true,
        onTap: (() -> Void)? = nil
    ) {
        self.pet = pet
        self.context = context
        self.isAnimating = isAnimating
        self.onTap = onTap
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

    /// Species-specific color palette for vibrant pets
    private var petPalette: PixelTheme.PetPalette {
        PixelTheme.PetPalette.palette(for: pet.species)
    }

    // MARK: - Equipped Accessories

    private var equippedHat: Accessory? { pet.equippedHat }
    private var equippedBackground: Accessory? { pet.equippedBackground }
    private var equippedEffect: Accessory? { pet.equippedEffect }

    /// Aura colors — overridden by fire/thunder effects
    private var outerAuraColors: [Color] {
        if let effect = equippedEffect, !pet.isAway {
            switch effect.id {
            case "effect_fire":
                return [Color.orange.opacity(0.5), Color.red.opacity(0.2), Color.clear]
            case "effect_lightning":
                return [Color(hex: "4488FF").opacity(0.5), Color.yellow.opacity(0.2), Color.clear]
            default: break
            }
        }
        return [petPalette.fill.opacity(0.5), petPalette.fill.opacity(0.2), Color.clear]
    }

    private var innerAuraColors: [Color] {
        if let effect = equippedEffect, !pet.isAway {
            switch effect.id {
            case "effect_fire":
                return [Color.orange.opacity(0.4), Color.red.opacity(0.15), Color.clear]
            case "effect_lightning":
                return [Color(hex: "4488FF").opacity(0.4), Color.yellow.opacity(0.15), Color.clear]
            default: break
            }
        }
        return [petPalette.highlight.opacity(0.4), petPalette.fill.opacity(0.15), Color.clear]
    }

    /// Habitat box dimensions
    private var habitatWidth: CGFloat { 32 * pixelSize + PixelScale.px(4) }
    private var habitatHeight: CGFloat { 32 * pixelSize + PixelScale.px(10) }

    var body: some View {
        VStack(spacing: PixelScale.px(2)) {
            // Pet sprite with animation
            ZStack {
                // Glow aura effect — color overridden by equipped effects
                if !pet.isAway {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: outerAuraColors,
                                center: .center,
                                startRadius: 0,
                                endRadius: 32 * pixelSize * 0.9
                            )
                        )
                        .frame(width: 32 * pixelSize * 1.6, height: 32 * pixelSize * 1.6)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: innerAuraColors,
                                center: .center,
                                startRadius: 0,
                                endRadius: 32 * pixelSize * 0.5
                            )
                        )
                        .frame(width: 32 * pixelSize * 1.2, height: 32 * pixelSize * 1.2)
                }

                // Background panel — habitat box with equipped background
                ZStack(alignment: .bottom) {
                    if let gradient = equippedBackground?.habitatGradient {
                        Rectangle()
                            .fill(gradient)
                            .frame(width: habitatWidth, height: habitatHeight)
                            .pixelOutline()
                    } else {
                        Rectangle()
                            .fill(PixelTheme.cardBackground)
                            .frame(width: habitatWidth, height: habitatHeight)
                            .pixelOutline()
                    }

                    // Themed background decorations
                    if let bg = equippedBackground {
                        backgroundDecorations(for: bg)
                            .frame(width: habitatWidth, height: habitatHeight)
                            .clipped()
                    } else {
                        // Default floor pattern when no background equipped
                        HStack(spacing: PixelScale.px(2)) {
                            ForEach(0..<5, id: \.self) { _ in
                                Rectangle()
                                    .fill(PixelTheme.gbLight.opacity(0.3))
                                    .frame(width: PixelScale.px(1), height: PixelScale.px(1))
                            }
                        }
                        .padding(.bottom, PixelScale.px(2))
                    }
                }

                // Animated sprite with species-specific colors
                AnimatedSpriteView(
                    animation: animation,
                    pixelSize: pixelSize,
                    isAnimating: isAnimating && !pet.isAway,
                    palette: petPalette,
                    currentYOffset: $animationYOffset
                )
                .opacity(pet.isAway ? 0.5 : 1.0)
                .offset(y: PixelScale.px(3) + bounceOffset)

                // Hat overlay
                if let hat = equippedHat, !pet.isAway,
                   let hatSprite = HatSpriteLibrary.sprite(for: hat.id),
                   let hatPalette = HatSpriteLibrary.palette(for: hat.id) {
                    PixelSpriteView(sprite: hatSprite, pixelSize: pixelSize, palette: hatPalette)
                        .offset(y: HatSpriteLibrary.verticalOffset(for: hat.id) * pixelSize + PixelScale.px(3) + bounceOffset + animationYOffset + (hat.id == "hat_halo" ? haloFloat : 0))
                }

                // Effect particles — rendered on top of pet and hat
                if let effect = equippedEffect, !pet.isAway {
                    effectView(for: effect)
                        .zIndex(1)
                        .allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
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
            .onAppear {
                // Halo bob animation
                if equippedHat?.id == "hat_halo" {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        haloFloat = -pixelSize
                    }
                }
            }

            // Pet info bar
            if context == .home || context == .detail {
                PixelPetInfoBar(pet: pet)
            }
        }
    }

    // MARK: - Effect View Builder

    @ViewBuilder
    private func effectView(for effect: Accessory) -> some View {
        let effectBounds = CGSize(width: habitatWidth, height: habitatHeight)

        switch effect.id {
        case "effect_hearts":
            PixelParticleEffect(
                icon: .heart,
                color: Color(hex: "FFD6E8"),
                particleCount: 10,
                style: .floatUp,
                bounds: effectBounds,
                iconSize: 14
            )
        case "effect_stars":
            PixelParticleEffect(
                icon: .star,
                color: Color(hex: "F0E6FF"),
                particleCount: 10,
                style: .twinkle,
                bounds: effectBounds,
                iconSize: 14
            )
        case "effect_fire":
            PixelParticleEffect(
                icon: .flame,
                color: Color(hex: "FFE0B2"),
                particleCount: 6,
                style: .flank,
                bounds: effectBounds,
                iconSize: 14
            )
        case "effect_sparkle":
            PixelParticleEffect(
                icon: .sparkle,
                color: Color(hex: "F0E6FF"),
                particleCount: 10,
                style: .floatUp,
                bounds: effectBounds,
                iconSize: 14
            )
        case "effect_lightning":
            PixelParticleEffect(
                icon: .bolt,
                color: Color(hex: "FFFDE0"),
                particleCount: 5,
                style: .flash,
                bounds: effectBounds,
                iconSize: 14
            )
        default:
            EmptyView()
        }
    }

    // MARK: - Background Decorations

    @ViewBuilder
    private func backgroundDecorations(for background: Accessory) -> some View {
        let pw = PixelScale.px(1)
        let size = CGSize(width: habitatWidth, height: habitatHeight)

        switch background.id {
        case "bg_gradient_blue":
            OceanDecorationView(pixelWidth: pw, bounds: size)
        case "bg_gradient_green":
            ForestDecorationView(pixelWidth: pw, bounds: size)
        case "bg_gradient_purple":
            TwilightDecorationView(pixelWidth: pw, bounds: size)
        case "bg_gradient_fire":
            InfernoDecorationView(pixelWidth: pw, bounds: size)
        case "bg_gradient_rainbow":
            RainbowDecorationView(pixelWidth: pw, bounds: size)
        case "bg_gradient_gold":
            GoldenHourDecorationView(pixelWidth: pw, bounds: size)
        default:
            EmptyView()
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

    @State private var dismissTask: DispatchWorkItem?

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
            scheduleDismiss()
        }
        .onChange(of: text) { _, _ in
            // Reset dismiss timer when text changes
            scheduleDismiss()
        }
        .onTapGesture {
            dismissTask?.cancel()
            isVisible = false
        }
    }

    private func scheduleDismiss() {
        // Cancel any existing dismiss task
        dismissTask?.cancel()

        // Schedule new dismiss after 4 seconds
        let task = DispatchWorkItem { [self] in
            isVisible = false
        }
        dismissTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: task)
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
