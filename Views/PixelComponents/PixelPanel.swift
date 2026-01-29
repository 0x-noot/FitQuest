import SwiftUI

// MARK: - Pixel Panel

/// A container panel with optional title bar, styled like classic game UI menus
struct PixelPanel<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar (if provided)
            if let title = title {
                HStack {
                    PixelText(title, size: .small)
                    Spacer()
                }
                .padding(.horizontal, PixelScale.px(2))
                .padding(.vertical, PixelScale.px(1))
                .background(PixelTheme.gbDark)
                .foregroundColor(PixelTheme.gbLightest)

                // Separator line
                Rectangle()
                    .fill(PixelTheme.border)
                    .frame(height: PixelScale.px(1))
            }

            // Content area
            content
                .padding(PixelScale.px(2))
        }
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }
}

// MARK: - Pixel Panel with Counter

/// Panel with a title and a counter value (e.g., "QUESTS 2/3")
struct PixelPanelWithCounter<Content: View>: View {
    let title: String
    let current: Int
    let total: Int
    let content: Content

    init(
        title: String,
        current: Int,
        total: Int,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.current = current
        self.total = total
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar with counter
            HStack {
                PixelText(title, size: .small, color: PixelTheme.gbLightest)
                Spacer()
                PixelText("\(current)/\(total)", size: .small, color: PixelTheme.gbLightest)
            }
            .padding(.horizontal, PixelScale.px(2))
            .padding(.vertical, PixelScale.px(1))
            .background(PixelTheme.gbDark)

            // Separator line
            Rectangle()
                .fill(PixelTheme.border)
                .frame(height: PixelScale.px(1))

            // Content area
            content
                .padding(PixelScale.px(2))
        }
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }
}

// MARK: - Pixel Window

/// A panel styled like a dialog window with thicker borders
struct PixelWindow<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                PixelText(title, size: .medium, color: PixelTheme.gbLightest)
                Spacer()
            }
            .padding(.horizontal, PixelScale.px(3))
            .padding(.vertical, PixelScale.px(2))
            .background(PixelTheme.gbDarkest)

            // Content area
            content
                .padding(PixelScale.px(3))
                .background(PixelTheme.cardBackground)
        }
        .pixelBorder(thickness: 2)
    }
}

// MARK: - Pixel Card

/// A simple card without title, just content with border
struct PixelCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(PixelScale.px(2))
            .background(PixelTheme.cardBackground)
            .pixelOutline()
    }
}

// MARK: - Pixel Stat Box

/// A compact box for displaying a single stat (value + label)
struct PixelStatBox: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: PixelScale.px(1)) {
            PixelText(value, size: .large)
            PixelLabel(label)
        }
        .frame(maxWidth: .infinity)
        .padding(PixelScale.px(2))
        .background(PixelTheme.cardBackground)
        .pixelOutline()
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            PixelPanel(title: "STATS") {
                VStack(spacing: 8) {
                    HStack {
                        PixelText("LEVEL", size: .small)
                        Spacer()
                        PixelText("12", size: .small)
                    }
                    HStack {
                        PixelText("XP", size: .small)
                        Spacer()
                        PixelText("450", size: .small)
                    }
                }
            }

            PixelPanelWithCounter(title: "QUESTS", current: 2, total: 3) {
                VStack(spacing: 4) {
                    PixelText("QUEST 1")
                    PixelText("QUEST 2")
                    PixelText("QUEST 3")
                }
            }

            PixelCard {
                PixelText("Simple card content")
            }

            HStack(spacing: 12) {
                PixelStatBox(value: "42", label: "STREAK")
                PixelStatBox(value: "1.2K", label: "XP")
            }
        }
        .padding(20)
    }
    .background(PixelTheme.background)
}
