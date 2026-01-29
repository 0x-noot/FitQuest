import SwiftUI

// MARK: - Pixel Progress Bar

/// An HP-bar style segmented progress bar like classic RPGs
struct PixelProgressBar: View {
    let progress: Double
    let segments: Int
    let showLabel: Bool
    let labelPrefix: String
    let height: CGFloat
    let onSegmentTap: ((Int) -> Void)?

    init(
        progress: Double,
        segments: Int = 10,
        showLabel: Bool = false,
        labelPrefix: String = "",
        height: CGFloat = PixelScale.px(3),
        onSegmentTap: ((Int) -> Void)? = nil
    ) {
        self.progress = min(1.0, max(0.0, progress))
        self.segments = segments
        self.showLabel = showLabel
        self.labelPrefix = labelPrefix
        self.height = height
        self.onSegmentTap = onSegmentTap
    }

    private var filledSegments: Int {
        Int(ceil(progress * Double(segments)))
    }

    var body: some View {
        VStack(spacing: PixelScale.px(1)) {
            if showLabel {
                HStack {
                    PixelText(labelPrefix, size: .small)
                    Spacer()
                    PixelText("\(Int(progress * 100))%", size: .small)
                }
            }

            HStack(spacing: PixelScale.px(1)) {
                ForEach(0..<segments, id: \.self) { index in
                    Rectangle()
                        .fill(index < filledSegments ? PixelTheme.gbDarkest : PixelTheme.gbLight)
                        .frame(height: height)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSegmentTap?(index)
                        }
                }
            }
            .padding(PixelScale.px(1))
            .background(PixelTheme.cardBackground)
            .pixelOutline()
        }
    }
}

// MARK: - XP Progress Bar

/// Specialized progress bar for XP display
struct PixelXPBar: View {
    let currentXP: Int
    let targetXP: Int
    let currentLevel: Int

    private var progress: Double {
        guard targetXP > 0 else { return 0 }
        return Double(currentXP) / Double(targetXP)
    }

    var body: some View {
        VStack(spacing: PixelScale.px(1)) {
            HStack {
                PixelText("XP", size: .small)
                Spacer()
                PixelText("LV.\(currentLevel + 1)", size: .small, color: PixelTheme.textSecondary)
            }

            PixelProgressBar(progress: progress, segments: 12)

            HStack {
                PixelText("\(currentXP)", size: .small, color: PixelTheme.textSecondary)
                Spacer()
                PixelText("\(targetXP)", size: .small, color: PixelTheme.textSecondary)
            }
        }
    }
}

// MARK: - Happiness Bar

/// Progress bar styled for pet happiness display
struct PixelHappinessBar: View {
    let happiness: Double
    let mood: PetMood

    var body: some View {
        VStack(spacing: PixelScale.px(1)) {
            HStack {
                PixelText(mood.emoji, size: .medium, uppercase: false)
                PixelText("\(Int(happiness))%", size: .small)
                Spacer()
                PixelText(mood.rawValue, size: .small, color: PixelTheme.textSecondary)
            }

            PixelProgressBar(progress: happiness / 100.0, segments: 10)
        }
    }
}

// MARK: - Weekly Progress Bar

/// Shows weekly workout progress (days completed / goal)
struct PixelWeeklyBar: View {
    let daysCompleted: Int
    let goal: Int

    var body: some View {
        VStack(spacing: PixelScale.px(1)) {
            HStack {
                PixelText("THIS WEEK", size: .small)
                Spacer()
                PixelText("\(daysCompleted)/\(goal)", size: .small)
            }

            HStack(spacing: PixelScale.px(1)) {
                ForEach(0..<goal, id: \.self) { index in
                    Rectangle()
                        .fill(index < daysCompleted ? PixelTheme.gbDarkest : PixelTheme.gbLight)
                        .frame(height: PixelScale.px(4))
                        .pixelOutline()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        PixelProgressBar(progress: 0.75, showLabel: true, labelPrefix: "HP")

        PixelProgressBar(progress: 0.3, segments: 8)

        PixelXPBar(currentXP: 340, targetXP: 500, currentLevel: 12)

        PixelHappinessBar(happiness: 85, mood: .happy)

        PixelWeeklyBar(daysCompleted: 3, goal: 5)
    }
    .padding(20)
    .background(PixelTheme.background)
}
