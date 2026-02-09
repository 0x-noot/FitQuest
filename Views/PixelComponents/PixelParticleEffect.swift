import SwiftUI

// MARK: - Particle Animation Style

enum ParticleAnimationStyle {
    case floatUp    // Hearts, sparkles — rise and fade
    case twinkle    // Stars — appear/disappear at random positions
    case flank      // Fire — sit at sides, pulse scale
    case flash      // Lightning — rapid opacity flash on alternating sides
}

// MARK: - Pixel Particle

struct PixelParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var scale: CGFloat
}

// MARK: - Pixel Particle Effect View

/// Renders animated pixel icon particles around the pet
struct PixelParticleEffect: View {
    let icon: PixelIcon
    let color: Color
    let particleCount: Int
    let style: ParticleAnimationStyle
    let bounds: CGSize
    let iconSize: CGFloat

    init(icon: PixelIcon, color: Color, particleCount: Int, style: ParticleAnimationStyle, bounds: CGSize, iconSize: CGFloat = 8) {
        self.icon = icon
        self.color = color
        self.particleCount = particleCount
        self.style = style
        self.bounds = bounds
        self.iconSize = iconSize
    }

    @State private var particles: [PixelParticle] = []
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                PixelIconView(icon: icon, size: iconSize, color: color)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
            }
        }
        .frame(width: bounds.width, height: bounds.height)
        .onAppear { startEffect() }
        .onDisappear { stopEffect() }
    }

    private func startEffect() {
        stopEffect()

        switch style {
        case .floatUp:
            startFloatUp()
        case .twinkle:
            startTwinkle()
        case .flank:
            startFlank()
        case .flash:
            startFlash()
        }
    }

    private func stopEffect() {
        timer?.invalidate()
        timer = nil
        particles = []
    }

    // MARK: - Float Up (Hearts, Sparkles)

    private func startFloatUp() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            guard particles.count < particleCount else { return }
            spawnFloatingParticle()
        }
        // Spawn initial particles
        spawnFloatingParticle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { spawnFloatingParticle() }
    }

    private func spawnFloatingParticle() {
        let centerX = bounds.width / 2
        let particle = PixelParticle(
            x: centerX + CGFloat.random(in: -bounds.width * 0.35...bounds.width * 0.35),
            y: bounds.height * 0.6,
            opacity: 1.0,
            scale: CGFloat.random(in: 0.8...1.2)
        )
        particles.append(particle)
        let index = particles.count - 1

        withAnimation(.easeOut(duration: 1.5)) {
            if index < particles.count {
                particles[index].y = bounds.height * 0.1
                particles[index].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if !particles.isEmpty {
                particles.removeFirst()
            }
        }
    }

    // MARK: - Twinkle (Stars)

    private func startTwinkle() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            guard particles.count < particleCount else { return }
            spawnTwinkleParticle()
        }
        // Seed a few immediately
        spawnTwinkleParticle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { spawnTwinkleParticle() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { spawnTwinkleParticle() }
    }

    private func spawnTwinkleParticle() {
        let particle = PixelParticle(
            x: CGFloat.random(in: bounds.width * 0.1...bounds.width * 0.9),
            y: CGFloat.random(in: bounds.height * 0.1...bounds.height * 0.7),
            opacity: 0,
            scale: CGFloat.random(in: 0.7...1.2)
        )
        particles.append(particle)
        let index = particles.count - 1

        // Fade in
        withAnimation(.easeIn(duration: 0.4)) {
            if index < particles.count {
                particles[index].opacity = 1.0
            }
        }

        // Fade out after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.4)) {
                if index < self.particles.count {
                    self.particles[index].opacity = 0
                }
            }
        }

        // Remove
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if !particles.isEmpty {
                particles.removeFirst()
            }
        }
    }

    // MARK: - Flank (Fire)

    private func startFlank() {
        // Place flames at fixed positions (left and right of pet)
        let leftFlame = PixelParticle(
            x: bounds.width * 0.15,
            y: bounds.height * 0.7,
            opacity: 0.8,
            scale: 0.8
        )
        let rightFlame = PixelParticle(
            x: bounds.width * 0.85,
            y: bounds.height * 0.7,
            opacity: 0.8,
            scale: 0.8
        )
        particles = [leftFlame, rightFlame]

        // Pulse animation
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            for i in 0..<particles.count {
                withAnimation(.easeInOut(duration: 0.4)) {
                    particles[i].scale = CGFloat.random(in: 0.8...1.3)
                    particles[i].opacity = Double.random(in: 0.7...1.0)
                }
            }
        }
    }

    // MARK: - Flash (Lightning)

    private func startFlash() {
        var leftSide = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            let x = leftSide ? bounds.width * 0.1 : bounds.width * 0.9
            let particle = PixelParticle(
                x: x,
                y: bounds.height * 0.4,
                opacity: 0,
                scale: 1.0
            )
            particles.append(particle)
            let index = particles.count - 1
            leftSide.toggle()

            // Flash in
            withAnimation(.easeIn(duration: 0.08)) {
                if index < particles.count {
                    particles[index].opacity = 1.0
                }
            }

            // Flash out
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.15)) {
                    if index < self.particles.count {
                        self.particles[index].opacity = 0
                    }
                }
            }

            // Remove
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !particles.isEmpty {
                    particles.removeFirst()
                }
            }
        }
    }
}
