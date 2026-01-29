import SwiftUI

struct OnboardingWelcomeStep: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            Spacer()

            // Pet icon preview using pixel sprite
            PixelIconView(icon: .paw, size: 64)
                .padding(PixelScale.px(4))
                .background(PixelTheme.cardBackground)
                .pixelBorder(thickness: 2)

            // Title
            VStack(spacing: PixelScale.px(2)) {
                PixelText("WELCOME TO", size: .medium, color: PixelTheme.textSecondary)
                PixelText("FITOGATCHI!", size: .xlarge)

                PixelText("YOUR FITNESS PET AWAITS", size: .small, color: PixelTheme.textSecondary)
            }

            // Tagline
            PixelText("RAISE YOUR PET BY WORKING OUT!", size: .small, color: PixelTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PixelScale.px(4))
                .padding(.top, PixelScale.px(4))

            Spacer()

            // Continue button
            PixelButton("GET STARTED >", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, PixelScale.px(4))
        }
        .padding(.vertical, PixelScale.px(4))
    }
}

#Preview {
    OnboardingWelcomeStep() {}
    .background(PixelTheme.background)
}
