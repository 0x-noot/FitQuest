import SwiftUI

struct OnboardingFocusStep: View {
    @Binding var selectedAreas: Set<FocusArea>
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            // Header
            VStack(spacing: PixelScale.px(1)) {
                PixelText("FOCUS AREAS", size: .xlarge)
                PixelText("WHICH MUSCLES TO PRIORITIZE?", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(.top, PixelScale.px(2))

            // Focus area options
            ScrollView {
                VStack(spacing: PixelScale.px(2)) {
                    ForEach(FocusArea.allCases) { area in
                        PixelMultiSelectCard(
                            title: area.displayName.uppercased(),
                            description: area.description.uppercased(),
                            isSelected: selectedAreas.contains(area)
                        ) {
                            if selectedAreas.contains(area) {
                                selectedAreas.remove(area)
                            } else {
                                selectedAreas.insert(area)
                            }
                        }
                    }
                }
                .padding(.horizontal, PixelScale.px(4))
            }

            // Continue button
            PixelButton("CONTINUE >", style: .primary) {
                onContinue()
            }
            .disabled(selectedAreas.isEmpty)
            .opacity(selectedAreas.isEmpty ? 0.5 : 1)
            .padding(.horizontal, PixelScale.px(4))
        }
        .padding(.vertical, PixelScale.px(4))
    }
}

#Preview {
    OnboardingFocusStep(
        selectedAreas: .constant([.chest, .back])
    ) {}
    .background(PixelTheme.background)
}
