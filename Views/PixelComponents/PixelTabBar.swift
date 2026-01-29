import SwiftUI

// MARK: - Tab Enum

enum PixelTab: String, CaseIterable {
    case home
    case history
    case profile

    var icon: PixelIcon {
        switch self {
        case .home: return .home
        case .history: return .scroll
        case .profile: return .person
        }
    }

    var label: String {
        switch self {
        case .home: return "HOME"
        case .history: return "LOG"
        case .profile: return "STATS"
        }
    }
}

// MARK: - Pixel Tab Bar

/// A custom tab bar styled with pixel art aesthetic
struct PixelTabBar: View {
    @Binding var selectedTab: PixelTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(PixelTab.allCases, id: \.rawValue) { tab in
                PixelTabItem(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.vertical, PixelScale.px(1))
        .padding(.bottom, PixelScale.px(1))  // Extra padding for safe area
        .background(PixelTheme.cardBackground)
        .overlay(
            Rectangle()
                .fill(PixelTheme.border)
                .frame(height: PixelScale.px(1)),
            alignment: .top
        )
    }
}

// MARK: - Pixel Tab Item

struct PixelTabItem: View {
    let tab: PixelTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: PixelScale.px(1)) {
                PixelIconView(
                    icon: tab.icon,
                    size: 18,
                    color: isSelected ? PixelTheme.gbLightest : PixelTheme.gbLightest.opacity(0.7)
                )
                PixelText(
                    tab.label,
                    size: .small,
                    color: isSelected ? PixelTheme.gbLightest : PixelTheme.gbLight
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PixelScale.px(2))
            .background(isSelected ? PixelTheme.gbDark : Color.clear)
        }
        .buttonStyle(.plain)
        .overlay(
            Group {
                if isSelected {
                    Rectangle()
                        .stroke(PixelTheme.gbLight, lineWidth: PixelScale.px(1))
                }
            }
        )
    }
}

// MARK: - Pixel Status Bar

/// Top status bar showing essence and streak
struct PixelStatusBar: View {
    let essence: Int
    let streak: Int

    var body: some View {
        HStack {
            // Essence
            HStack(spacing: PixelScale.px(1)) {
                PixelIconView(icon: .sparkle, size: 14, color: PixelTheme.gbLightest)
                PixelText("\(essence)", size: .small, color: PixelTheme.gbLightest)
            }
            .padding(.horizontal, PixelScale.px(2))
            .padding(.vertical, PixelScale.px(1))
            .background(PixelTheme.cardBackground)
            .pixelOutline()

            Spacer()

            // Streak
            HStack(spacing: PixelScale.px(1)) {
                PixelIconView(icon: .flame, size: 14, color: PixelTheme.gbLightest)
                PixelText("\(streak)", size: .small, color: PixelTheme.gbLightest)
            }
            .padding(.horizontal, PixelScale.px(2))
            .padding(.vertical, PixelScale.px(1))
            .background(PixelTheme.cardBackground)
            .pixelOutline()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()

        PixelStatusBar(essence: 150, streak: 7)
            .padding()

        Spacer()

        PixelTabBar(selectedTab: .constant(.home))
    }
    .background(PixelTheme.background)
}
