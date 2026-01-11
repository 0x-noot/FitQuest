import SwiftUI

struct XPProgressBar: View {
    let progress: Double
    let currentXP: Int
    let targetXP: Int
    var animated: Bool = true

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.xpBarBackground)

                    // Fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.xpBarGradient)
                        .frame(width: max(0, geometry.size.width * (animated ? animatedProgress : progress)))
                }
            }
            .frame(height: 12)

            // XP Text
            HStack {
                Text("\(currentXP.formatted()) / \(targetXP.formatted()) XP")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textSecondary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.primary)
            }
        }
        .onAppear {
            if animated {
                withAnimation(.spring(duration: 0.8)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            if animated {
                withAnimation(.spring(duration: 0.5)) {
                    animatedProgress = newValue
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        XPProgressBar(progress: 0.78, currentXP: 2450, targetXP: 3150)
        XPProgressBar(progress: 0.25, currentXP: 500, targetXP: 2000)
        XPProgressBar(progress: 0.95, currentXP: 950, targetXP: 1000)
    }
    .padding()
    .background(Theme.background)
}
