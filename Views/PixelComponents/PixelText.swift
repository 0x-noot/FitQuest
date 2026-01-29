import SwiftUI

// MARK: - Pixel Text

/// Text component styled for pixel art aesthetic
/// Uses monospace font with uppercase letters for authentic retro look
struct PixelText: View {
    let text: String
    let size: PixelFontSize
    let color: Color
    let uppercase: Bool

    init(
        _ text: String,
        size: PixelFontSize = .medium,
        color: Color = PixelTheme.text,
        uppercase: Bool = true
    ) {
        self.text = text
        self.size = size
        self.color = color
        self.uppercase = uppercase
    }

    var body: some View {
        Text(uppercase ? text.uppercased() : text)
            .font(.custom("Menlo-Bold", size: size.pointSize))
            .tracking(1)
            .foregroundColor(color)
            .lineSpacing(size.lineSpacing)
    }
}

// MARK: - Pixel Title

/// Larger title text for headers and important labels
struct PixelTitle: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color = PixelTheme.text) {
        self.text = text
        self.color = color
    }

    var body: some View {
        PixelText(text, size: .large, color: color)
    }
}

// MARK: - Pixel Label

/// Small label text for hints and secondary information
struct PixelLabel: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color = PixelTheme.textSecondary) {
        self.text = text
        self.color = color
    }

    var body: some View {
        PixelText(text, size: .small, color: color)
    }
}

// MARK: - Pixel Number

/// Styled number display (for stats, XP, etc.)
struct PixelNumber: View {
    let value: Int
    let prefix: String
    let suffix: String
    let size: PixelFontSize
    let color: Color

    init(
        _ value: Int,
        prefix: String = "",
        suffix: String = "",
        size: PixelFontSize = .medium,
        color: Color = PixelTheme.text
    ) {
        self.value = value
        self.prefix = prefix
        self.suffix = suffix
        self.size = size
        self.color = color
    }

    var body: some View {
        HStack(spacing: 2) {
            if !prefix.isEmpty {
                PixelText(prefix, size: size, color: color)
            }
            PixelText("\(value)", size: size, color: color, uppercase: false)
            if !suffix.isEmpty {
                PixelText(suffix, size: size, color: color)
            }
        }
    }
}

// MARK: - Blinking Text Effect

/// Text that blinks like classic game prompts
struct PixelBlinkingText: View {
    let text: String
    let size: PixelFontSize
    let color: Color
    let interval: Double

    @State private var isVisible = true

    init(
        _ text: String,
        size: PixelFontSize = .medium,
        color: Color = PixelTheme.text,
        interval: Double = 0.5
    ) {
        self.text = text
        self.size = size
        self.color = color
        self.interval = interval
    }

    var body: some View {
        PixelText(text, size: size, color: color)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                    isVisible.toggle()
                }
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        PixelText("PIXEL TEXT", size: .xlarge)
        PixelTitle("TITLE")
        PixelText("Medium body text")
        PixelLabel("Small label")
        PixelNumber(1234, prefix: "XP:", suffix: "")
        PixelNumber(42, prefix: "", suffix: "%")
        PixelBlinkingText("PRESS START")
    }
    .padding(40)
    .background(PixelTheme.background)
}
