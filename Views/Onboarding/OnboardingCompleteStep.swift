import SwiftUI

struct OnboardingCompleteStep: View {
    let playerName: String
    let character: CharacterAppearance
    let weeklyGoal: Int
    let onComplete: () -> Void

    @State private var animateIn = false
    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Celebration elements
            ZStack {
                // Confetti background
                if showConfetti {
                    ForEach(0..<12) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor([Theme.primary, Theme.secondary, Theme.warning, Theme.success][index % 4])
                            .offset(
                                x: CGFloat.random(in: -100...100),
                                y: CGFloat.random(in: -150...-50)
                            )
                            .opacity(animateIn ? 0 : 1)
                            .animation(
                                .easeOut(duration: 1.5).delay(Double(index) * 0.1),
                                value: animateIn
                            )
                    }
                }

                // Character
                CharacterDisplayView(appearance: character, size: 160)
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
            }

            // Title
            VStack(spacing: 12) {
                Text("Your quest begins!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)

                Text("Welcome, \(playerName)!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 20)
            }

            // Summary card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "target")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.primary)

                    Text("Weekly Goal")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Spacer()

                    Text("\(weeklyGoal) workouts")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                }

                Divider()
                    .background(Theme.elevated)

                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.streakGradient)

                    Text("Starting Streak")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Spacer()

                    Text("0 weeks")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                }
            }
            .padding(20)
            .background(Theme.cardBackground)
            .cornerRadius(16)
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 30)

            Spacer()

            // Start button
            PrimaryButton("Let's Go!", icon: "arrow.right") {
                onComplete()
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .onAppear {
            showConfetti = true
            withAnimation(.spring(duration: 0.8)) {
                animateIn = true
            }
        }
    }
}

#Preview {
    OnboardingCompleteStep(
        playerName: "John",
        character: CharacterAppearance(),
        weeklyGoal: 4
    ) {}
    .background(Theme.background)
}
