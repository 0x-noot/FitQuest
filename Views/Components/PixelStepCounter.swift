import SwiftUI

struct PixelStepCounter: View {
    let steps: Int
    let goal: Int
    let unclaimedXP: Int
    let isLoading: Bool
    let authStatus: HealthKitManager.AuthStatus
    let onClaim: () -> Void
    let onRequestAuth: () -> Void

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(steps) / Double(goal))
    }

    var body: some View {
        VStack(spacing: PixelScale.px(1)) {
            // Header row
            HStack {
                PixelIconView(icon: .run, size: 12, color: PixelTheme.gbLightest)
                PixelText("STEPS", size: .small, color: PixelTheme.text)
                Spacer()

                switch authStatus {
                case .authorized:
                    if isLoading {
                        PixelText("...", size: .small, color: PixelTheme.textSecondary)
                    } else {
                        PixelText("\(steps.formatted())", size: .small, color: PixelTheme.gbLightest)
                    }
                case .notDetermined:
                    Button { onRequestAuth() } label: {
                        PixelText("SYNC", size: .small, color: PixelTheme.gbLightest)
                    }
                    .buttonStyle(.plain)
                case .denied, .unavailable:
                    PixelText("N/A", size: .small, color: PixelTheme.textSecondary)
                }
            }

            if authStatus == .authorized {
                // Progress bar
                PixelProgressBar(
                    progress: progress,
                    segments: 10,
                    height: PixelScale.px(2)
                )

                // Footer row: goal text + claim button
                HStack {
                    PixelText(
                        "\(steps.formatted())/\(goal.formatted())",
                        size: .small,
                        color: PixelTheme.textSecondary
                    )

                    Spacer()

                    if unclaimedXP > 0 {
                        Button { onClaim() } label: {
                            HStack(spacing: PixelScale.px(1)) {
                                PixelIconView(icon: .star, size: 10, color: PixelTheme.gbLightest)
                                PixelText("+\(unclaimedXP) XP", size: .small, color: PixelTheme.gbLightest)
                            }
                            .padding(.horizontal, PixelScale.px(2))
                            .padding(.vertical, PixelScale.px(1))
                            .background(PixelTheme.gbDark)
                            .pixelOutline()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(PixelScale.px(2))
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }
}
