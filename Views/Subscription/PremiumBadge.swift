import SwiftUI

struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: PixelScale.px(1)) {
            PixelIconView(icon: .star, size: 10, color: PixelTheme.gbLightest)
            PixelText("PREMIUM", size: .small, color: PixelTheme.gbLightest)
        }
        .padding(.horizontal, PixelScale.px(2))
        .padding(.vertical, PixelScale.px(1))
        .background(PixelTheme.gbDark)
        .overlay(
            RoundedRectangle(cornerRadius: PixelScale.cornerRadius)
                .stroke(PixelTheme.gbLight, lineWidth: PixelTheme.borderThin)
        )
    }
}
