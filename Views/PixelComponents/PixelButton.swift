import SwiftUI

// MARK: - Pixel Button

/// A button styled like classic game UI with press effect
struct PixelButton: View {
    let label: String
    let icon: PixelIcon?
    let style: PixelButtonStyle
    let action: () -> Void

    @State private var isPressed = false

    init(
        _ label: String,
        icon: PixelIcon? = nil,
        style: PixelButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: PixelScale.px(2)) {
                if let icon = icon {
                    PixelIconView(icon: icon, size: 14, color: style.textColor)
                }
                PixelText(label, size: .medium, color: style.textColor)
            }
            .frame(maxWidth: style.fullWidth ? .infinity : nil)
            .padding(.horizontal, PixelScale.px(4))
            .padding(.vertical, PixelScale.px(2))
            .background(isPressed ? style.pressedBackground : style.background)
            .pixelOutline(color: style.borderColor)
            .offset(y: isPressed ? PixelScale.px(1) : 0)
        }
        .buttonStyle(PixelPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Button Styles

enum PixelButtonStyle {
    case primary
    case secondary
    case small
    case danger

    var background: Color {
        switch self {
        case .primary: return PixelTheme.gbDark
        case .secondary: return PixelTheme.cardBackground
        case .small: return PixelTheme.cardBackground
        case .danger: return PixelTheme.gbDarkest
        }
    }

    var pressedBackground: Color {
        switch self {
        case .primary: return PixelTheme.gbDarkest
        case .secondary: return PixelTheme.gbDark
        case .small: return PixelTheme.gbDark
        case .danger: return PixelTheme.gbDark
        }
    }

    var textColor: Color {
        switch self {
        case .primary: return PixelTheme.gbLightest
        case .secondary: return PixelTheme.text
        case .small: return PixelTheme.text
        case .danger: return PixelTheme.gbLightest
        }
    }

    var borderColor: Color {
        PixelTheme.border
    }

    var fullWidth: Bool {
        switch self {
        case .primary, .danger: return true
        case .secondary, .small: return false
        }
    }
}

// MARK: - Press Button Style

struct PixelPressStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Pixel Icon Button

/// A compact icon-only button for action grids
struct PixelIconButton: View {
    let icon: PixelIcon
    let label: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: PixelScale.px(1)) {
                PixelIconView(icon: icon, size: 20, color: PixelTheme.gbLightest)
                PixelText(label, size: .small, color: PixelTheme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PixelScale.px(3))
            .background(isPressed ? PixelTheme.gbDark : PixelTheme.cardBackground)
            .pixelOutline()
            .offset(y: isPressed ? PixelScale.px(1) : 0)
        }
        .buttonStyle(PixelPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Pixel Small Button

/// A small inline button (for +/- controls, etc.)
struct PixelSmallButton: View {
    let label: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            PixelText(label, size: .medium)
                .frame(width: PixelScale.px(6), height: PixelScale.px(6))
                .background(isPressed ? PixelTheme.gbDark : PixelTheme.cardBackground)
                .pixelOutline()
        }
        .buttonStyle(PixelPressStyle(isPressed: $isPressed))
    }
}

// MARK: - Pixel Toggle

/// A toggle switch styled for pixel art
struct PixelToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack {
                PixelText(label, size: .small)
                Spacer()
                // Toggle indicator
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(isOn ? PixelTheme.gbDarkest : PixelTheme.cardBackground)
                        .frame(width: PixelScale.px(4), height: PixelScale.px(3))
                    Rectangle()
                        .fill(isOn ? PixelTheme.cardBackground : PixelTheme.gbDarkest)
                        .frame(width: PixelScale.px(4), height: PixelScale.px(3))
                }
                .pixelOutline()
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PixelButton("PRIMARY", style: .primary) { }

        PixelButton("WITH ICON", icon: .heart, style: .primary) { }

        PixelButton("SECONDARY", style: .secondary) { }

        HStack(spacing: 12) {
            PixelIconButton(icon: .dumbbell, label: "WORK") { }
            PixelIconButton(icon: .heart, label: "FEED") { }
            PixelIconButton(icon: .star, label: "SHOP") { }
        }

        HStack(spacing: 8) {
            PixelSmallButton(label: "-") { }
            PixelText("10")
            PixelSmallButton(label: "+") { }
        }

        PixelToggle(label: "SOUND", isOn: .constant(true))
        PixelToggle(label: "NOTIFY", isOn: .constant(false))
    }
    .padding(30)
    .background(PixelTheme.background)
}
