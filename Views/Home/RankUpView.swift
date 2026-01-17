import SwiftUI

struct RankUpView: View {
    let rank: PlayerRank
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = -180
    @State private var showParticles = false

    var body: some View {
        ZStack {
            Theme.background.opacity(0.95)
                .ignoresSafeArea()

            // Animated particles
            if showParticles {
                ParticleEffect(color: rank.color)
            }

            VStack(spacing: 30) {
                Spacer()

                // Rank icon with glow effect
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(rank.color.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                            .frame(width: CGFloat(140 + index * 30), height: CGFloat(140 + index * 30))
                            .scaleEffect(showParticles ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: showParticles
                            )
                    }

                    // Main badge circle
                    Circle()
                        .fill(rank.gradient)
                        .frame(width: 120, height: 120)
                        .shadow(color: rank.color.opacity(0.6), radius: 20)

                    // Rank icon
                    Image(systemName: rank.iconName)
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotation))
                }
                .scaleEffect(scale)

                VStack(spacing: 12) {
                    Text("RANK UP!")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(rank.gradient)

                    Text("You've achieved")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Text(rank.displayName.uppercased())
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(rank.gradient)

                    Text(rank.levelRange)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                        .padding(.top, 4)

                    if let nextRank = rank.nextRank {
                        Text("Next: \(nextRank.displayName) at Level \(nextRank.minLevel)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.textMuted)
                            .padding(.top, 8)
                    } else {
                        Text("Maximum rank achieved!")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(rank.color)
                            .padding(.top, 8)
                    }
                }

                Spacer()

                PrimaryButton("Continue") {
                    onDismiss()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8, bounce: 0.4)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.spring(duration: 1.0)) {
                rotation = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showParticles = true
            }
        }
    }
}

// Simple particle effect for celebration
struct ParticleEffect: View {
    let color: Color
    @State private var particles: [(id: Int, x: CGFloat, y: CGFloat, opacity: Double)] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles, id: \.id) { particle in
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        for i in 0..<20 {
            let startX = size.width / 2
            let startY = size.height / 2
            let endX = CGFloat.random(in: 0...size.width)
            let endY = CGFloat.random(in: 0...size.height)

            particles.append((id: i, x: startX, y: startY, opacity: 1.0))

            withAnimation(.easeOut(duration: 1.5).delay(Double(i) * 0.05)) {
                if let index = particles.firstIndex(where: { $0.id == i }) {
                    particles[index].x = endX
                    particles[index].y = endY
                    particles[index].opacity = 0
                }
            }
        }
    }
}

#Preview {
    RankUpView(rank: .gold) {
        print("Dismissed")
    }
}
