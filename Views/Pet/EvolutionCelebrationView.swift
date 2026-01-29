import SwiftUI

struct EvolutionCelebrationView: View {
    let petName: String
    let species: PetSpecies
    let newStage: EvolutionStage
    let onDismiss: () -> Void

    @State private var showOldStage = true
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var particleOpacity: Double = 0

    private var oldStage: EvolutionStage {
        switch newStage {
        case .baby: return .baby
        case .child: return .baby
        case .teen: return .child
        case .adult: return .teen
        }
    }

    var body: some View {
        ZStack {
            // Background
            Theme.background.opacity(0.98)
                .ignoresSafeArea()

            // Animated particles background
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(newStage.auraColor)
                    .frame(width: CGFloat.random(in: 10...30))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
                    .opacity(particleOpacity * Double.random(in: 0.3...1.0))
            }

            VStack(spacing: 30) {
                Spacer()

                // Evolution text
                Text("EVOLUTION!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.warning, Theme.primary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(opacity)

                // Pet transformation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [newStage.auraColor, .clear],
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .opacity(glowOpacity)

                    // Old stage (fades out)
                    if showOldStage {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Theme.cardBackground)
                                    .frame(width: 160, height: 160)

                                Image(systemName: species.iconName(for: oldStage))
                                    .font(.system(size: 80 * oldStage.iconScale))
                                    .foregroundColor(oldStage.badgeColor)
                            }

                            Text(oldStage.displayName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.textMuted)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }

                    // New stage (fades in)
                    if !showOldStage {
                        VStack(spacing: 8) {
                            ZStack {
                                // Aura ring
                                Circle()
                                    .stroke(newStage.auraColor, lineWidth: 4)
                                    .frame(width: 180, height: 180)
                                    .blur(radius: 5)

                                Circle()
                                    .fill(Theme.cardBackground)
                                    .frame(width: 160, height: 160)

                                Image(systemName: species.iconName(for: newStage))
                                    .font(.system(size: 80 * newStage.iconScale))
                                    .foregroundColor(newStage.badgeColor)
                            }

                            Text(newStage.displayName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(newStage.badgeColor)
                        }
                        .scaleEffect(scale)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .frame(height: 220)

                // Pet name
                Text(petName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .opacity(opacity)

                // Stage description
                Text(newStage.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(opacity)

                // Next evolution hint
                if let nextLevel = newStage.levelToEvolve {
                    Text("Next evolution at Level \(nextLevel)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                        .padding(.top, 8)
                        .opacity(opacity)
                } else {
                    Text("Maximum evolution reached!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.warning)
                        .padding(.top, 8)
                        .opacity(opacity)
                }

                Spacer()

                PrimaryButton("Amazing!") {
                    onDismiss()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(opacity)
            }
        }
        .onAppear {
            runEvolutionAnimation()
        }
    }

    private func runEvolutionAnimation() {
        // Phase 1: Show old stage with glow building
        withAnimation(.easeIn(duration: 0.5)) {
            opacity = 1
            glowOpacity = 0.3
        }

        // Phase 2: Flash and switch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                glowOpacity = 1.0
                particleOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showOldStage = false
                }

                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.0
                }

                withAnimation(.easeOut(duration: 0.5)) {
                    glowOpacity = newStage.glowIntensity
                    particleOpacity = 0.3
                }
            }
        }
    }
}

#Preview {
    EvolutionCelebrationView(
        petName: "Ember",
        species: .dragon,
        newStage: .teen,
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}
