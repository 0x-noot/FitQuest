import SwiftUI

// MARK: - Animated Pet Modifier

struct AnimatedPetModifier: ViewModifier {
    let mood: PetMood
    let isAway: Bool

    @State private var animationPhase: CGFloat = 0
    @State private var bounceOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var swayOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(y: bounceOffset)
            .offset(x: swayOffset)
            .rotationEffect(.degrees(rotationAngle + mood.rotationAmount))
            .saturation(isAway ? 0.3 : mood.saturation)
            .opacity(isAway ? 0.5 : 1.0)
            .onAppear {
                startAnimation()
            }
            .onChange(of: mood) { _, _ in
                startAnimation()
            }
    }

    private func startAnimation() {
        guard !isAway else {
            bounceOffset = 0
            swayOffset = 0
            rotationAngle = 0
            return
        }

        let duration = mood.animationSpeed
        let bounce = mood.bounceAmount * 100  // Convert to points

        switch mood.idleAnimationType {
        case .bounce:
            // Energetic bouncing
            withAnimation(
                .easeInOut(duration: duration * 0.5)
                .repeatForever(autoreverses: true)
            ) {
                bounceOffset = -bounce
            }
            withAnimation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true)
            ) {
                rotationAngle = 3
            }

        case .sway:
            // Side-to-side swaying
            withAnimation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true)
            ) {
                swayOffset = bounce * 0.5
            }
            withAnimation(
                .easeInOut(duration: duration * 0.8)
                .repeatForever(autoreverses: true)
            ) {
                bounceOffset = -bounce * 0.3
            }

        case .breathe:
            // Gentle breathing (handled by scale in parent view)
            bounceOffset = 0
            swayOffset = 0
            rotationAngle = 0

        case .droop:
            // Slow downward drift
            withAnimation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true)
            ) {
                bounceOffset = bounce * 0.5
            }

        case .shiver:
            // Small rapid shaking
            withAnimation(
                .easeInOut(duration: 0.1)
                .repeatForever(autoreverses: true)
            ) {
                swayOffset = bounce * 0.3
            }

        case .collapse:
            // Minimal movement with slight droop
            withAnimation(.easeOut(duration: 1.0)) {
                bounceOffset = bounce
                rotationAngle = -5
            }
        }
    }
}

extension View {
    func animatedPet(mood: PetMood, isAway: Bool) -> some View {
        modifier(AnimatedPetModifier(mood: mood, isAway: isAway))
    }
}

// MARK: - Mood-Based Scale Animation

struct MoodScaleModifier: ViewModifier {
    let mood: PetMood
    let isAway: Bool

    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                startScaleAnimation()
            }
            .onChange(of: mood) { _, _ in
                startScaleAnimation()
            }
    }

    private func startScaleAnimation() {
        guard !isAway else {
            scale = 1.0
            return
        }

        let duration = mood.animationSpeed
        let scaleAmount = 1.0 + mood.bounceAmount

        withAnimation(
            .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)
        ) {
            scale = scaleAmount
        }
    }
}

extension View {
    func moodScale(mood: PetMood, isAway: Bool) -> some View {
        modifier(MoodScaleModifier(mood: mood, isAway: isAway))
    }
}

// MARK: - Sparkle Effect for Ecstatic Mood

struct SparkleEffect: View {
    let isActive: Bool

    @State private var sparkles: [SparkleParticle] = []

    struct SparkleParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
    }

    var body: some View {
        ZStack {
            ForEach(sparkles) { sparkle in
                Image(systemName: "sparkle")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.warning)
                    .scaleEffect(sparkle.scale)
                    .opacity(sparkle.opacity)
                    .position(x: sparkle.x, y: sparkle.y)
            }
        }
        .onAppear {
            if isActive {
                startSparkles()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startSparkles()
            } else {
                sparkles = []
            }
        }
    }

    private func startSparkles() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            guard isActive else {
                timer.invalidate()
                return
            }
            spawnSparkle()
        }
    }

    private func spawnSparkle() {
        let sparkle = SparkleParticle(
            x: CGFloat.random(in: 20...120),
            y: CGFloat.random(in: 20...120),
            scale: CGFloat.random(in: 0.5...1.0),
            opacity: 1.0
        )

        sparkles.append(sparkle)
        let index = sparkles.count - 1

        withAnimation(.easeOut(duration: 0.8)) {
            if index < sparkles.count {
                sparkles[index].opacity = 0
                sparkles[index].scale = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !sparkles.isEmpty {
                sparkles.removeFirst()
            }
        }
    }
}

// MARK: - Tear Drop Effect for Sad Moods

struct TearDropEffect: View {
    let mood: PetMood
    let size: CGFloat

    @State private var tearOffset: CGFloat = 0
    @State private var tearOpacity: Double = 0

    var showTears: Bool {
        mood == .unhappy || mood == .miserable
    }

    var body: some View {
        Group {
            if showTears {
                Image(systemName: "drop.fill")
                    .font(.system(size: size * 0.08))
                    .foregroundColor(.blue.opacity(0.6))
                    .offset(x: size * 0.15, y: tearOffset)
                    .opacity(tearOpacity)
            }
        }
        .onAppear {
            if showTears {
                startTearAnimation()
            }
        }
        .onChange(of: mood) { _, _ in
            if showTears {
                startTearAnimation()
            } else {
                tearOpacity = 0
            }
        }
    }

    private func startTearAnimation() {
        tearOffset = 0
        tearOpacity = 0

        withAnimation(.easeIn(duration: 0.3)) {
            tearOpacity = 1
        }

        withAnimation(
            .easeIn(duration: 1.5)
            .repeatForever(autoreverses: false)
        ) {
            tearOffset = size * 0.3
        }

        // Fade out and reset
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            tearOpacity = 0
            tearOffset = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    tearOpacity = 1
                }
                withAnimation(.easeIn(duration: 1.5)) {
                    tearOffset = size * 0.3
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        // Ecstatic pet
        ZStack {
            Circle()
                .fill(PetMood.ecstatic.color.opacity(0.2))
                .frame(width: 100, height: 100)

            Image(systemName: "cat.fill")
                .font(.system(size: 50))
                .foregroundColor(PetMood.ecstatic.color)
                .animatedPet(mood: .ecstatic, isAway: false)
                .moodScale(mood: .ecstatic, isAway: false)

            SparkleEffect(isActive: true)
                .frame(width: 140, height: 140)
        }

        // Sad pet
        ZStack {
            Circle()
                .fill(PetMood.sad.color.opacity(0.2))
                .frame(width: 100, height: 100)

            Image(systemName: "cat.fill")
                .font(.system(size: 50))
                .foregroundColor(PetMood.sad.color)
                .animatedPet(mood: .sad, isAway: false)
                .moodScale(mood: .sad, isAway: false)
        }

        // Miserable pet with tears
        ZStack {
            Circle()
                .fill(PetMood.miserable.color.opacity(0.2))
                .frame(width: 100, height: 100)

            Image(systemName: "cat.fill")
                .font(.system(size: 50))
                .foregroundColor(PetMood.miserable.color)
                .animatedPet(mood: .miserable, isAway: false)
                .moodScale(mood: .miserable, isAway: false)

            TearDropEffect(mood: .miserable, size: 100)
        }
    }
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
