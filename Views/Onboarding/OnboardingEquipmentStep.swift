import SwiftUI

struct OnboardingEquipmentStep: View {
    @Binding var selectedEquipment: Set<EquipmentAccess>
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            // Header
            VStack(spacing: PixelScale.px(1)) {
                PixelText("EQUIPMENT?", size: .xlarge)
                PixelText("SELECT ALL (OPTIONAL)", size: .small, color: PixelTheme.textSecondary)
            }
            .padding(.top, PixelScale.px(2))

            // Equipment options
            ScrollView {
                VStack(spacing: PixelScale.px(2)) {
                    ForEach(EquipmentAccess.allCases) { equipment in
                        PixelMultiSelectCard(
                            title: equipment.displayName.uppercased(),
                            description: equipment.description.uppercased(),
                            isSelected: selectedEquipment.contains(equipment)
                        ) {
                            if selectedEquipment.contains(equipment) {
                                selectedEquipment.remove(equipment)
                            } else {
                                selectedEquipment.insert(equipment)
                            }
                        }
                    }
                }
                .padding(.horizontal, PixelScale.px(4))
            }

            // Buttons
            VStack(spacing: PixelScale.px(2)) {
                PixelButton("CONTINUE >", style: .primary) {
                    onContinue()
                }

                Button(action: onSkip) {
                    PixelText("SKIP FOR NOW", size: .small, color: PixelTheme.textSecondary)
                }
            }
            .padding(.horizontal, PixelScale.px(4))
        }
        .padding(.vertical, PixelScale.px(4))
    }
}

#Preview {
    OnboardingEquipmentStep(
        selectedEquipment: .constant([.fullGym])
    ) {} onSkip: {}
    .background(PixelTheme.background)
}
