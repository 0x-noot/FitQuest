import SwiftUI

struct OnboardingFocusStep: View {
    @Binding var selectedAreas: Set<FocusArea>
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Focus areas")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Which muscle groups do you want to prioritize?")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            // Focus area options
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(FocusArea.allCases) { area in
                        MultiSelectCard(
                            title: area.displayName,
                            description: area.description,
                            iconName: area.iconName,
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
            }

            // Continue button
            PrimaryButton("Continue", icon: "arrow.right") {
                onContinue()
            }
            .disabled(selectedAreas.isEmpty)
            .opacity(selectedAreas.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

#Preview {
    OnboardingFocusStep(
        selectedAreas: .constant([.chest, .back])
    ) {}
    .background(Theme.background)
}
