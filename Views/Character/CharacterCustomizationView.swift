import SwiftUI
import SwiftData

struct CharacterCustomizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var character: CharacterAppearance
    var playerRank: PlayerRank = .bronze

    @State private var selectedTab: CustomizationTab = .body

    enum CustomizationTab: String, CaseIterable {
        case body = "Body"
        case hair = "Hair"
        case outfit = "Outfit"
        case background = "BG"

        var icon: String {
            switch self {
            case .body: return "person.fill"
            case .hair: return "comb.fill"
            case .outfit: return "tshirt.fill"
            case .background: return "photo.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Character preview
                VStack(spacing: 16) {
                    CharacterDisplayView(appearance: character, size: 180)
                        .padding(.top, 20)

                    Text("Drag to rotate")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                .background(Theme.cardBackground)

                // Tab selector
                HStack(spacing: 0) {
                    ForEach(CustomizationTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 18))
                                Text(tab.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(selectedTab == tab ? Theme.primary : Theme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedTab == tab ?
                                Theme.primary.opacity(0.1) : Color.clear
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Theme.elevated)

                // Options
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case .body:
                            bodyOptions
                        case .hair:
                            hairOptions
                        case .outfit:
                            outfitOptions
                        case .background:
                            backgroundOptions
                        }
                    }
                    .padding(20)
                }
            }
            .background(Theme.background)
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.cardBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .foregroundColor(Theme.primary)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var bodyOptions: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Body type
            VStack(alignment: .leading, spacing: 12) {
                Text("Body Type")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        let labels = ["Slim", "Medium", "Athletic"]
                        optionButton(
                            label: labels[index],
                            isSelected: character.bodyType == index,
                            action: { character.bodyType = index }
                        )
                    }
                }
            }

            // Skin tone
            VStack(alignment: .leading, spacing: 12) {
                Text("Skin Tone")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 10) {
                    ForEach(0..<CharacterAppearance.skinTones.count, id: \.self) { index in
                        colorSwatch(
                            color: CharacterAppearance.skinTones[index],
                            isSelected: character.skinTone == index,
                            action: { character.skinTone = index }
                        )
                    }
                }
            }

            // Eye style
            VStack(alignment: .leading, spacing: 12) {
                Text("Eyes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 12) {
                    ForEach(0..<4) { index in
                        optionButton(
                            label: "Style \(index + 1)",
                            isSelected: character.eyeStyle == index,
                            action: { character.eyeStyle = index }
                        )
                    }
                }
            }
        }
    }

    private var hairOptions: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Hair style
            VStack(alignment: .leading, spacing: 12) {
                Text("Hairstyle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(0..<8) { index in
                        optionButton(
                            label: "Style \(index + 1)",
                            isSelected: character.hairStyle == index,
                            action: { character.hairStyle = index }
                        )
                    }
                }
            }

            // Hair color
            VStack(alignment: .leading, spacing: 12) {
                Text("Hair Color")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 10) {
                    ForEach(0..<CharacterAppearance.hairColors.count, id: \.self) { index in
                        let isLocked = index >= 6 // Purple and blue are locked
                        colorSwatch(
                            color: CharacterAppearance.hairColors[index],
                            isSelected: character.hairColor == index,
                            isLocked: isLocked,
                            action: {
                                if !isLocked {
                                    character.hairColor = index
                                }
                            }
                        )
                    }
                }

                if character.hairColor < 6 {
                    Text("Unlock more colors by leveling up!")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textMuted)
                }
            }
        }
    }

    private var outfitOptions: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Top
            VStack(alignment: .leading, spacing: 12) {
                Text("Top")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 10) {
                    ForEach(0..<CharacterAppearance.outfitColors.count, id: \.self) { index in
                        colorSwatch(
                            color: CharacterAppearance.outfitColors[index],
                            isSelected: character.top == index,
                            action: { character.top = index }
                        )
                    }
                }
            }

            // Bottom
            VStack(alignment: .leading, spacing: 12) {
                Text("Bottom")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 10) {
                    ForEach(0..<CharacterAppearance.outfitColors.count, id: \.self) { index in
                        colorSwatch(
                            color: CharacterAppearance.outfitColors[index],
                            isSelected: character.bottom == index,
                            action: { character.bottom = index }
                        )
                    }
                }
            }

            // Headwear
            VStack(alignment: .leading, spacing: 12) {
                Text("Headwear")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 12) {
                    optionButton(
                        label: "None",
                        isSelected: character.headwear == nil,
                        action: { character.headwear = nil }
                    )

                    optionButton(
                        label: "Cap",
                        isSelected: character.headwear == 1,
                        action: { character.headwear = 1 }
                    )

                    optionButton(
                        label: "Headband",
                        isSelected: character.headwear == 2,
                        isLocked: true,
                        lockText: "Lv.10",
                        action: { }
                    )
                }
            }
        }
    }

    private var backgroundOptions: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Character Background")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textSecondary)

            VStack(spacing: 12) {
                ForEach(CharacterBackground.allCases) { bg in
                    let isUnlocked = bg.isUnlocked(for: playerRank)
                    let isSelected = character.background == bg

                    Button {
                        if isUnlocked {
                            character.background = bg
                        }
                    } label: {
                        HStack(spacing: 16) {
                            // Preview gradient
                            RoundedRectangle(cornerRadius: 8)
                                .fill(bg.gradient)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: bg.iconName)
                                        .font(.system(size: 20))
                                        .foregroundColor(bg.accentColor)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(bg.displayName)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(isUnlocked ? Theme.textPrimary : Theme.textMuted)

                                Text(bg.description)
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textMuted)

                                if !isUnlocked, let rank = bg.unlockRank {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 10))
                                        Text("Reach \(rank.displayName) rank")
                                            .font(.system(size: 11))
                                    }
                                    .foregroundColor(rank.color)
                                }
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Theme.primary)
                            } else if !isUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                        .padding(12)
                        .background(isSelected ? Theme.primary.opacity(0.1) : Theme.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(isSelected ? Theme.primary : Theme.elevated, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isUnlocked)
                }
            }
        }
    }

    private func optionButton(
        label: String,
        isSelected: Bool,
        isLocked: Bool = false,
        lockText: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isLocked ? Theme.textMuted : (isSelected ? Theme.primary : Theme.textPrimary))

                if isLocked, let text = lockText {
                    HStack(spacing: 2) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8))
                        Text(text)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(Theme.textMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Theme.primary.opacity(0.2) : Theme.cardBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? Theme.primary : Theme.elevated, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    private func colorSwatch(
        color: Color,
        isSelected: Bool,
        isLocked: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 36, height: 36)

                if isSelected {
                    Circle()
                        .strokeBorder(Theme.textPrimary, lineWidth: 3)
                        .frame(width: 36, height: 36)
                }

                if isLocked {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 36, height: 36)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }
}

#Preview {
    CharacterCustomizationView(character: CharacterAppearance())
        .modelContainer(for: [CharacterAppearance.self], inMemory: true)
}
