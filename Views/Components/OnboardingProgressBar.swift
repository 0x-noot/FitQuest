import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    private var progress: CGFloat {
        guard totalSteps > 0 else { return 0 }
        return CGFloat(currentStep) / CGFloat(totalSteps)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.elevated)
                    .frame(height: 6)

                // Progress fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.primaryGradient)
                    .frame(width: geometry.size.width * progress, height: 6)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: 1, totalSteps: 9)
        OnboardingProgressBar(currentStep: 5, totalSteps: 9)
        OnboardingProgressBar(currentStep: 9, totalSteps: 9)
    }
    .padding()
    .background(Theme.background)
}
