import SwiftUI

struct SelectionCard: View {
    let title: String
    let description: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Theme.primary.opacity(0.2) : Theme.elevated)
                        .frame(width: 44, height: 44)

                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? Theme.primary : Theme.textSecondary)
                }

                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text(description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.textMuted)
                        .lineLimit(2)
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Theme.primary : Theme.textMuted.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Theme.primary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct MultiSelectCard: View {
    let title: String
    let description: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Theme.primary.opacity(0.2) : Theme.elevated)
                        .frame(width: 44, height: 44)

                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? Theme.primary : Theme.textSecondary)
                }

                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text(description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.textMuted)
                        .lineLimit(2)
                }

                Spacer()

                // Checkbox indicator
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Theme.primary : Theme.textMuted.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Theme.primary)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Theme.primary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        SelectionCard(
            title: "Beginner",
            description: "New to working out",
            iconName: "leaf.fill",
            isSelected: false
        ) {}

        SelectionCard(
            title: "Intermediate",
            description: "Regular exercise routine",
            iconName: "flame.fill",
            isSelected: true
        ) {}

        MultiSelectCard(
            title: "Build Muscle",
            description: "Get stronger and build lean muscle",
            iconName: "dumbbell.fill",
            isSelected: true
        ) {}

        MultiSelectCard(
            title: "Lose Weight",
            description: "Burn calories and shed pounds",
            iconName: "scalemass.fill",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Theme.background)
}
