import SwiftUI

struct OnboardingLevelStep: View {
    @Binding var selectedLevel: FitnessLevel?
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            // Header
            VStack(spacing: PixelScale.px(1)) {
                PixelText("FITNESS LEVEL?", size: .xlarge)
                PixelText("BE HONEST - WE'LL TAILOR IT", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(.top, PixelScale.px(2))

            Spacer()

            // Level options
            VStack(spacing: PixelScale.px(2)) {
                ForEach(FitnessLevel.allCases) { level in
                    OnboardingSelectionCard(
                        title: level.displayName.uppercased(),
                        description: level.description.uppercased(),
                        isSelected: selectedLevel == level
                    ) {
                        selectedLevel = level
                    }
                }
            }
            .padding(.horizontal, PixelScale.px(4))

            Spacer()

            // Continue button
            PixelButton("CONTINUE >", style: .primary) {
                onContinue()
            }
            .disabled(selectedLevel == nil)
            .opacity(selectedLevel == nil ? 0.5 : 1)
            .padding(.horizontal, PixelScale.px(4))
        }
        .padding(.vertical, PixelScale.px(4))
    }
}

// MARK: - Onboarding Selection Card

struct OnboardingSelectionCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PixelScale.px(2)) {
                VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                    PixelText(title, size: .small)
                    PixelText(description, size: .small, color: PixelTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    PixelIconView(icon: .check, size: 16)
                }
            }
            .padding(PixelScale.px(2))
            .background(isSelected ? PixelTheme.gbDark.opacity(0.3) : PixelTheme.cardBackground)
            .pixelOutline()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingLevelStep(
        selectedLevel: .constant(.intermediate)
    ) {}
    .background(PixelTheme.background)
}
