import SwiftUI

struct OnboardingEquipmentStep: View {
    @Binding var selectedEquipment: Set<EquipmentAccess>
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("What equipment do you have?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Select all that apply (optional)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(.top, 8)

            // Equipment options
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(EquipmentAccess.allCases) { equipment in
                        MultiSelectCard(
                            title: equipment.displayName,
                            description: equipment.description,
                            iconName: equipment.iconName,
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
            }

            // Buttons
            VStack(spacing: 12) {
                PrimaryButton("Continue", icon: "arrow.right") {
                    onContinue()
                }

                Button(action: onSkip) {
                    Text("Skip for now")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    OnboardingEquipmentStep(
        selectedEquipment: .constant([.fullGym])
    ) {} onSkip: {}
    .background(Theme.background)
}
