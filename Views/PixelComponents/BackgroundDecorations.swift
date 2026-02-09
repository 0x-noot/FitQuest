import SwiftUI

// MARK: - Ocean Wave Decoration

/// Animated pixel waves and bubbles for the Ocean Wave background
struct OceanDecorationView: View {
    let pixelWidth: CGFloat
    let bounds: CGSize

    @State private var waveOffset: CGFloat = 0
    @State private var bubbles: [DecoParticle] = []
    @State private var timer: Timer?

    var body: some View {
        ZStack(alignment: .bottom) {
            // Wave rows
            VStack(spacing: 0) {
                Spacer()
                waveRow(yPhase: 0, color: Color.cyan.opacity(0.2))
                waveRow(yPhase: pixelWidth * 2, color: Color.cyan.opacity(0.3))
                waveRow(yPhase: pixelWidth, color: Color(hex: "2A4A5A").opacity(0.5))
            }

            // Bubbles
            ForEach(bubbles) { bubble in
                Rectangle()
                    .fill(Color.cyan.opacity(0.4))
                    .frame(width: pixelWidth, height: pixelWidth)
                    .opacity(bubble.opacity)
                    .position(x: bubble.x, y: bubble.y)
            }
        }
        .frame(width: bounds.width, height: bounds.height)
        .clipped()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                waveOffset = pixelWidth * 3
            }
            startBubbles()
        }
        .onDisappear { timer?.invalidate() }
    }

    private func waveRow(yPhase: CGFloat, color: Color) -> some View {
        HStack(spacing: pixelWidth) {
            ForEach(0..<Int(bounds.width / (pixelWidth * 2)), id: \.self) { i in
                Rectangle()
                    .fill(color)
                    .frame(width: pixelWidth, height: pixelWidth)
                    .offset(y: (i % 2 == 0 ? -pixelWidth : 0) + waveOffset * (i % 2 == 0 ? 0.3 : -0.3))
            }
        }
        .frame(height: pixelWidth * 2)
        .offset(x: waveOffset * 0.2 + yPhase)
    }

    private func startBubbles() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            guard bubbles.count < 3 else { return }
            let bubble = DecoParticle(
                x: CGFloat.random(in: bounds.width * 0.2...bounds.width * 0.8),
                y: bounds.height * 0.8,
                opacity: 0.6
            )
            bubbles.append(bubble)
            let index = bubbles.count - 1

            withAnimation(.easeOut(duration: 2.5)) {
                if index < bubbles.count {
                    bubbles[index].y = bounds.height * 0.2
                    bubbles[index].opacity = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                if !bubbles.isEmpty { bubbles.removeFirst() }
            }
        }
    }
}

// MARK: - Forest Decoration

/// Pixel grass and tree silhouettes for the Forest background
struct ForestDecorationView: View {
    let pixelWidth: CGFloat
    let bounds: CGSize

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tree silhouettes on left
            treeSilhouette()
                .position(x: bounds.width * 0.1, y: bounds.height * 0.55)

            // Tree silhouette on right
            treeSilhouette()
                .position(x: bounds.width * 0.9, y: bounds.height * 0.5)

            // Grass row at bottom
            HStack(spacing: 0) {
                ForEach(0..<Int(bounds.width / pixelWidth), id: \.self) { i in
                    VStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(Color.green.opacity(Double.random(in: 0.25...0.45)))
                            .frame(width: pixelWidth, height: pixelWidth * CGFloat(i % 3 == 0 ? 3 : (i % 2 == 0 ? 2 : 1)))
                    }
                }
            }
            .frame(height: pixelWidth * 4)
        }
        .frame(width: bounds.width, height: bounds.height)
        .clipped()
    }

    private func treeSilhouette() -> some View {
        VStack(spacing: 0) {
            // Canopy
            Rectangle()
                .fill(Color.green.opacity(0.2))
                .frame(width: pixelWidth * 3, height: pixelWidth)
            Rectangle()
                .fill(Color.green.opacity(0.25))
                .frame(width: pixelWidth * 5, height: pixelWidth)
            Rectangle()
                .fill(Color.green.opacity(0.3))
                .frame(width: pixelWidth * 5, height: pixelWidth)
            Rectangle()
                .fill(Color.green.opacity(0.25))
                .frame(width: pixelWidth * 3, height: pixelWidth)
            // Trunk
            Rectangle()
                .fill(Color(hex: "2A4A2A").opacity(0.4))
                .frame(width: pixelWidth, height: pixelWidth * 3)
        }
    }
}

// MARK: - Twilight Decoration

/// Twinkling pixel stars and crescent moon for the Twilight background
struct TwilightDecorationView: View {
    let pixelWidth: CGFloat
    let bounds: CGSize

    private let starPositions: [(CGFloat, CGFloat)] = [
        (0.15, 0.12), (0.75, 0.18), (0.4, 0.08),
        (0.25, 0.35), (0.6, 0.3), (0.85, 0.45),
        (0.5, 0.5), (0.12, 0.55)
    ]

    @State private var starOpacities: [Double] = Array(repeating: 0.2, count: 8)

    var body: some View {
        ZStack {
            // Twinkling stars
            ForEach(0..<starPositions.count, id: \.self) { i in
                Rectangle()
                    .fill(Color(hex: "D8B4FE"))
                    .frame(width: pixelWidth, height: pixelWidth)
                    .opacity(starOpacities[i])
                    .position(
                        x: bounds.width * starPositions[i].0,
                        y: bounds.height * starPositions[i].1
                    )
            }

            // Crescent moon (top-right area)
            moonShape()
                .position(x: bounds.width * 0.82, y: bounds.height * 0.15)
        }
        .frame(width: bounds.width, height: bounds.height)
        .clipped()
        .onAppear { startTwinkling() }
    }

    private func moonShape() -> some View {
        // 4x4 pixel crescent
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
                Rectangle().fill(Color(hex: "D8B4FE").opacity(0.7)).frame(width: pixelWidth, height: pixelWidth)
                Rectangle().fill(Color(hex: "D8B4FE").opacity(0.8)).frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
            }
            HStack(spacing: 0) {
                Rectangle().fill(Color(hex: "D8B4FE").opacity(0.8)).frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
            }
            HStack(spacing: 0) {
                Rectangle().fill(Color(hex: "D8B4FE").opacity(0.8)).frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
            }
            HStack(spacing: 0) {
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
                Rectangle().fill(Color(hex: "D8B4FE").opacity(0.7)).frame(width: pixelWidth, height: pixelWidth)
                Rectangle().fill(Color(hex: "D8B4FE").opacity(0.8)).frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
            }
        }
    }

    private func startTwinkling() {
        for i in 0..<starPositions.count {
            let delay = Double(i) * 0.4
            let duration = 1.5 + Double(i % 3) * 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    starOpacities[i] = Double.random(in: 0.6...0.9)
                }
            }
        }
    }
}

// MARK: - Inferno Decoration

/// Lava floor and rising embers for the Inferno background
struct InfernoDecorationView: View {
    let pixelWidth: CGFloat
    let bounds: CGSize

    @State private var embers: [DecoParticle] = []
    @State private var timer: Timer?
    @State private var lavaGlow: Double = 0.4

    var body: some View {
        ZStack(alignment: .bottom) {
            // Rising embers
            ForEach(embers) { ember in
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: pixelWidth, height: pixelWidth)
                    .opacity(ember.opacity)
                    .position(x: ember.x, y: ember.y)
            }

            // Lava floor — jagged pattern
            HStack(spacing: 0) {
                ForEach(0..<Int(bounds.width / pixelWidth), id: \.self) { i in
                    VStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(i % 3 == 1 ? Color.orange.opacity(lavaGlow) : Color.red.opacity(lavaGlow * 0.8))
                            .frame(width: pixelWidth, height: pixelWidth * CGFloat(i % 4 == 0 ? 3 : (i % 2 == 0 ? 2 : 1)))
                    }
                }
            }
            .frame(height: pixelWidth * 4)
        }
        .frame(width: bounds.width, height: bounds.height)
        .clipped()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                lavaGlow = 0.7
            }
            startEmbers()
        }
        .onDisappear { timer?.invalidate() }
    }

    private func startEmbers() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            guard embers.count < 4 else { return }
            let ember = DecoParticle(
                x: CGFloat.random(in: bounds.width * 0.15...bounds.width * 0.85),
                y: bounds.height * 0.85,
                opacity: 0.8
            )
            embers.append(ember)
            let index = embers.count - 1

            withAnimation(.easeOut(duration: 2.0)) {
                if index < embers.count {
                    embers[index].y = bounds.height * CGFloat.random(in: 0.1...0.3)
                    embers[index].opacity = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                if !embers.isEmpty { embers.removeFirst() }
            }
        }
    }
}

// MARK: - Rainbow Decoration

/// Shimmering horizontal color bands for the Rainbow background
struct RainbowDecorationView: View {
    let pixelWidth: CGFloat
    let bounds: CGSize

    private let bandColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple
    ]

    @State private var bandOpacities: [Double] = Array(repeating: 0.1, count: 6)

    var body: some View {
        ZStack {
            ForEach(0..<bandColors.count, id: \.self) { i in
                Rectangle()
                    .fill(bandColors[i])
                    .frame(width: bounds.width * 0.8, height: pixelWidth)
                    .opacity(bandOpacities[i])
                    .position(
                        x: bounds.width / 2,
                        y: bounds.height * (0.15 + CGFloat(i) * 0.12)
                    )
            }
        }
        .frame(width: bounds.width, height: bounds.height)
        .clipped()
        .onAppear { startShimmer() }
    }

    private func startShimmer() {
        for i in 0..<bandColors.count {
            let delay = Double(i) * 0.35
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    bandOpacities[i] = 0.3
                }
            }
        }
    }
}

// MARK: - Golden Hour Decoration

/// Pixel sun, rays, and warm glow particles for the Golden Hour background
struct GoldenHourDecorationView: View {
    let pixelWidth: CGFloat
    let bounds: CGSize

    @State private var glowParticles: [DecoParticle] = []
    @State private var timer: Timer?
    @State private var rayOpacity: Double = 0.15

    private let goldColor = Color(hex: "FFD700")

    var body: some View {
        ZStack {
            // Diagonal sun rays
            ForEach(0..<3, id: \.self) { i in
                Rectangle()
                    .fill(goldColor.opacity(rayOpacity))
                    .frame(width: pixelWidth, height: bounds.height * 0.5)
                    .rotationEffect(.degrees(25 + Double(i) * 15))
                    .position(
                        x: bounds.width * (0.12 + CGFloat(i) * 0.08),
                        y: bounds.height * 0.35
                    )
            }

            // Pixel sun (top-left)
            sunShape()
                .position(x: bounds.width * 0.12, y: bounds.height * 0.12)

            // Warm glow particles
            ForEach(glowParticles) { particle in
                Rectangle()
                    .fill(goldColor.opacity(0.5))
                    .frame(width: pixelWidth, height: pixelWidth)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
            }
        }
        .frame(width: bounds.width, height: bounds.height)
        .clipped()
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                rayOpacity = 0.3
            }
            startGlowParticles()
        }
        .onDisappear { timer?.invalidate() }
    }

    private func sunShape() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
                Rectangle().fill(goldColor.opacity(0.6)).frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
            }
            HStack(spacing: 0) {
                Rectangle().fill(goldColor.opacity(0.6)).frame(width: pixelWidth, height: pixelWidth)
                Rectangle().fill(goldColor.opacity(0.8)).frame(width: pixelWidth, height: pixelWidth)
                Rectangle().fill(goldColor.opacity(0.6)).frame(width: pixelWidth, height: pixelWidth)
            }
            HStack(spacing: 0) {
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
                Rectangle().fill(goldColor.opacity(0.6)).frame(width: pixelWidth, height: pixelWidth)
                Color.clear.frame(width: pixelWidth, height: pixelWidth)
            }
        }
    }

    private func startGlowParticles() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            guard glowParticles.count < 3 else { return }
            let particle = DecoParticle(
                x: CGFloat.random(in: bounds.width * 0.1...bounds.width * 0.5),
                y: CGFloat.random(in: bounds.height * 0.2...bounds.height * 0.6),
                opacity: 0.6
            )
            glowParticles.append(particle)
            let index = glowParticles.count - 1

            withAnimation(.easeOut(duration: 3.0)) {
                if index < glowParticles.count {
                    glowParticles[index].y -= bounds.height * 0.15
                    glowParticles[index].opacity = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                if !glowParticles.isEmpty { glowParticles.removeFirst() }
            }
        }
    }
}

// MARK: - Shared Particle Model

struct DecoParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
}
