import SwiftUI

struct OnboardingStyleStep: View {
    @Binding var selectedStyle: WorkoutStyle?
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            // Header
            VStack(spacing: PixelScale.px(1)) {
                PixelText("WORKOUT STYLE?", size: .xlarge)
                PixelText("CHOOSE YOUR TRAINING TYPE", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(.top, PixelScale.px(2))

            Spacer()

            // Style options
            VStack(spacing: PixelScale.px(2)) {
                ForEach(WorkoutStyle.allCases) { style in
                    OnboardingSelectionCard(
                        title: style.displayName.uppercased(),
                        description: style.description.uppercased(),
                        isSelected: selectedStyle == style
                    ) {
                        selectedStyle = style
                    }
                }
            }
            .padding(.horizontal, PixelScale.px(4))

            Spacer()

            // Continue button
            PixelButton("CONTINUE >", style: .primary) {
                onContinue()
            }
            .disabled(selectedStyle == nil)
            .opacity(selectedStyle == nil ? 0.5 : 1)
            .padding(.horizontal, PixelScale.px(4))
        }
        .padding(.vertical, PixelScale.px(4))
    }
}

#Preview {
    OnboardingStyleStep(
        selectedStyle: .constant(.balanced)
    ) {}
    .background(PixelTheme.background)
}
