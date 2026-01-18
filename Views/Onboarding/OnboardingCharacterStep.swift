import SwiftUI

struct OnboardingCharacterStep: View {
    @Binding var character: CharacterAppearance
    let onContinue: () -> Void

    @State private var selectedCategory: CharacterCategory = .bodyType

    enum CharacterCategory: String, CaseIterable {
        case bodyType = "Body"
        case skinTone = "Skin"
        case hairStyle = "Hair"
        case hairColor = "Color"
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Create your character")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Customize your avatar")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }

            // Character preview
            CharacterDisplayView(appearance: character, size: 140)
                .padding(.vertical, 12)

            // Category tabs
            HStack(spacing: 8) {
                ForEach(CharacterCategory.allCases, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedCategory == category ? .white : Theme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Theme.primary : Theme.cardBackground)
                            )
                    }
                }
            }

            // Options for selected category
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    switch selectedCategory {
                    case .bodyType:
                        ForEach(0..<3) { index in
                            bodyTypeOption(index: index)
                        }
                    case .skinTone:
                        ForEach(0..<CharacterAppearance.skinTones.count, id: \.self) { index in
                            skinToneOption(index: index)
                        }
                    case .hairStyle:
                        ForEach(0..<4) { index in
                            hairStyleOption(index: index)
                        }
                    case .hairColor:
                        ForEach(0..<6, id: \.self) { index in
                            hairColorOption(index: index)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 70)
            .padding(.vertical, 8)

            Spacer()

            // Continue button
            PrimaryButton("Continue", icon: "arrow.right") {
                onContinue()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private func bodyTypeOption(index: Int) -> some View {
        let labels = ["Slim", "Medium", "Muscular"]
        return Button(action: { character.bodyType = index }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(character.bodyType == index ? Theme.primary.opacity(0.2) : Theme.cardBackground)
                        .frame(width: 56, height: 56)

                    Image(systemName: "figure.stand")
                        .font(.system(size: 24))
                        .foregroundColor(character.bodyType == index ? Theme.primary : Theme.textSecondary)
                }

                Text(labels[index])
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(character.bodyType == index ? Theme.primary : Theme.textMuted)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(character.bodyType == index ? Theme.primary : Color.clear, lineWidth: 2)
                .frame(width: 56, height: 56)
                .offset(y: -7)
        )
    }

    private func skinToneOption(index: Int) -> some View {
        Button(action: { character.skinTone = index }) {
            Circle()
                .fill(CharacterAppearance.skinTones[index])
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(character.skinTone == index ? Theme.primary : Color.clear, lineWidth: 3)
                )
        }
    }

    private func hairStyleOption(index: Int) -> some View {
        let labels = ["Short", "Curved", "Flat", "Long"]
        return Button(action: { character.hairStyle = index }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(character.hairStyle == index ? Theme.primary.opacity(0.2) : Theme.cardBackground)
                        .frame(width: 56, height: 56)

                    Text("\(index + 1)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(character.hairStyle == index ? Theme.primary : Theme.textSecondary)
                }

                Text(labels[index])
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(character.hairStyle == index ? Theme.primary : Theme.textMuted)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(character.hairStyle == index ? Theme.primary : Color.clear, lineWidth: 2)
                .frame(width: 56, height: 56)
                .offset(y: -7)
        )
    }

    private func hairColorOption(index: Int) -> some View {
        Button(action: { character.hairColor = index }) {
            Circle()
                .fill(CharacterAppearance.hairColors[index])
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(character.hairColor == index ? Theme.primary : Color.clear, lineWidth: 3)
                )
        }
    }
}

#Preview {
    OnboardingCharacterStep(
        character: .constant(CharacterAppearance())
    ) {}
    .background(Theme.background)
}
