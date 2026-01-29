import SwiftUI

struct HeartParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var rotation: Double
}

struct HeartParticleView: View {
    @Binding var isAnimating: Bool
    let particleCount: Int
    let size: CGFloat

    @State private var particles: [HeartParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: "heart.fill")
                    .font(.system(size: 16 * particle.scale))
                    .foregroundColor(Theme.secondary.opacity(particle.opacity))
                    .rotationEffect(.degrees(particle.rotation))
                    .position(x: particle.x, y: particle.y)
            }
        }
        .frame(width: size, height: size)
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                spawnParticles()
            }
        }
    }

    private func spawnParticles() {
        particles = []
        let center = size / 2

        for i in 0..<particleCount {
            let delay = Double(i) * 0.05
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 30...80)
            let endX = center + cos(angle) * distance
            let endY = center + sin(angle) * distance - 30  // Bias upward

            var particle = HeartParticle(
                x: center,
                y: center,
                scale: CGFloat.random(in: 0.6...1.2),
                opacity: 1.0,
                rotation: Double.random(in: -30...30)
            )

            particles.append(particle)
            let particleIndex = particles.count - 1

            // Animate the particle
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.8)) {
                    if particleIndex < particles.count {
                        particles[particleIndex].x = endX
                        particles[particleIndex].y = endY
                        particles[particleIndex].opacity = 0
                        particles[particleIndex].scale = particles[particleIndex].scale * 0.5
                    }
                }
            }
        }

        // Clean up particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            particles = []
            isAnimating = false
        }
    }
}

struct PlaySessionCompleteView: View {
    let sessionsRemaining: Int
    @Binding var isVisible: Bool

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.system(size: 32))
                .foregroundColor(Theme.secondary)

            Text("+\(Int(Pet.happinessPerSession))% Happiness!")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            if sessionsRemaining > 0 {
                Text("\(sessionsRemaining) play\(sessionsRemaining == 1 ? "" : "s") left today")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            } else {
                Text("Come back tomorrow!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textMuted)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.cardBackground)
                .shadow(color: .black.opacity(0.3), radius: 20)
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }

            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    scale = 0.8
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isVisible = false
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.background
            .ignoresSafeArea()

        VStack(spacing: 40) {
            // Heart particle preview
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.2))
                    .frame(width: 140, height: 140)

                Image(systemName: "cat.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.primary)

                HeartParticleView(
                    isAnimating: .constant(true),
                    particleCount: 8,
                    size: 200
                )
            }

            // Session complete preview
            PlaySessionCompleteView(
                sessionsRemaining: 2,
                isVisible: .constant(true)
            )
        }
    }
    .preferredColorScheme(.dark)
}
