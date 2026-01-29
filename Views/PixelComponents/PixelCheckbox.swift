import SwiftUI

// MARK: - Pixel Checkbox

/// A pixel-art styled checkbox for quest items
struct PixelCheckbox: View {
    let isChecked: Bool
    let canClaim: Bool
    let onTap: (() -> Void)?

    init(isChecked: Bool, canClaim: Bool = false, onTap: (() -> Void)? = nil) {
        self.isChecked = isChecked
        self.canClaim = canClaim
        self.onTap = onTap
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack {
                // Box background
                Rectangle()
                    .fill(canClaim ? PixelTheme.gbDark : PixelTheme.cardBackground)
                    .frame(width: PixelScale.px(4), height: PixelScale.px(4))
                    .pixelOutline()

                // Checkmark (when checked)
                if isChecked {
                    PixelCheckmark()
                        .stroke(PixelTheme.gbDarkest, lineWidth: PixelScale.px(1))
                        .frame(width: PixelScale.px(2.5), height: PixelScale.px(2.5))
                }
            }
        }
        .disabled(onTap == nil)
        .buttonStyle(.plain)
    }
}

// MARK: - Pixel Checkmark Shape

/// A pixelated checkmark shape
struct PixelCheckmark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Simple L-shaped checkmark
        path.move(to: CGPoint(x: 0, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.35, y: h))
        path.addLine(to: CGPoint(x: w, y: 0))

        return path
    }
}

// MARK: - Pixel Radio Button

/// A pixel-art styled radio button for single selection
struct PixelRadioButton: View {
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer circle (as square for pixel look)
                Rectangle()
                    .fill(PixelTheme.cardBackground)
                    .frame(width: PixelScale.px(4), height: PixelScale.px(4))
                    .pixelOutline()

                // Inner filled square when selected
                if isSelected {
                    Rectangle()
                        .fill(PixelTheme.gbDarkest)
                        .frame(width: PixelScale.px(2), height: PixelScale.px(2))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quest Row

/// A complete quest row with checkbox, text, and reward
struct PixelQuestRow: View {
    let quest: DailyQuest
    let onClaim: () -> Void

    private var canClaim: Bool {
        quest.isCompleted && !quest.isRewardClaimed
    }

    var body: some View {
        HStack(spacing: PixelScale.px(2)) {
            // Checkbox
            PixelCheckbox(
                isChecked: quest.isCompleted,
                canClaim: canClaim,
                onTap: canClaim ? onClaim : nil
            )

            // Quest name
            PixelText(
                quest.questType.displayName.uppercased(),
                size: .small,
                color: quest.isRewardClaimed ? PixelTheme.textSecondary : PixelTheme.text
            )
            .strikethrough(quest.isRewardClaimed)

            Spacer()

            // Reward
            if !quest.isRewardClaimed {
                HStack(spacing: PixelScale.px(1)) {
                    PixelText(
                        "+\(quest.questType.rewardAmount)",
                        size: .small,
                        color: PixelTheme.textSecondary
                    )
                    PixelText(
                        quest.questType.rewardType == .xp ? "XP" : "ESS",
                        size: .small,
                        color: PixelTheme.textSecondary
                    )
                }
            }
        }
        .padding(.vertical, PixelScale.px(1))
        .opacity(quest.isRewardClaimed ? 0.6 : 1.0)
    }
}

// MARK: - Selection Card

/// A selectable card for multi-choice options
struct PixelSelectionCard: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let onTap: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: PixelScale.px(1)) {
                    PixelText(title, size: .medium)
                    if let subtitle = subtitle {
                        PixelLabel(subtitle)
                    }
                }
                Spacer()
                PixelRadioButton(isSelected: isSelected, onTap: onTap)
            }
            .padding(PixelScale.px(2))
            .background(isSelected ? PixelTheme.gbDark : PixelTheme.cardBackground)
            .pixelOutline()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 20) {
            PixelCheckbox(isChecked: false)
            PixelCheckbox(isChecked: true)
            PixelCheckbox(isChecked: true, canClaim: true) { }
        }

        HStack(spacing: 20) {
            PixelRadioButton(isSelected: false) { }
            PixelRadioButton(isSelected: true) { }
        }

        Divider()

        VStack(spacing: 8) {
            PixelSelectionCard(
                title: "OPTION A",
                subtitle: "This is the first option",
                isSelected: true
            ) { }

            PixelSelectionCard(
                title: "OPTION B",
                subtitle: "This is the second option",
                isSelected: false
            ) { }
        }
    }
    .padding(20)
    .background(PixelTheme.background)
}
