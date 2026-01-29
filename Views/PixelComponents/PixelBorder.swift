import SwiftUI

// MARK: - Pixel Border Shape

/// A shape that creates chunky pixel-art style borders with stepped corners
/// Similar to classic Game Boy and Pokemon menu boxes
struct PixelBorderShape: Shape {
    let thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let t = thickness

        // Outer rectangle with notched corners for pixel look
        // Top edge
        path.move(to: CGPoint(x: t, y: 0))
        path.addLine(to: CGPoint(x: rect.width - t, y: 0))

        // Top-right corner (stepped)
        path.addLine(to: CGPoint(x: rect.width - t, y: t))
        path.addLine(to: CGPoint(x: rect.width, y: t))

        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - t))

        // Bottom-right corner (stepped)
        path.addLine(to: CGPoint(x: rect.width - t, y: rect.height - t))
        path.addLine(to: CGPoint(x: rect.width - t, y: rect.height))

        // Bottom edge
        path.addLine(to: CGPoint(x: t, y: rect.height))

        // Bottom-left corner (stepped)
        path.addLine(to: CGPoint(x: t, y: rect.height - t))
        path.addLine(to: CGPoint(x: 0, y: rect.height - t))

        // Left edge
        path.addLine(to: CGPoint(x: 0, y: t))

        // Top-left corner (stepped)
        path.addLine(to: CGPoint(x: t, y: t))
        path.addLine(to: CGPoint(x: t, y: 0))

        path.closeSubpath()

        return path
    }
}

// MARK: - Pixel Border Modifier

/// A view modifier that adds a chunky pixel-art border around content
struct PixelBorderModifier: ViewModifier {
    let thickness: Int
    let filled: Bool
    let fillColor: Color
    let borderColor: Color

    init(
        thickness: Int = 2,
        filled: Bool = true,
        fillColor: Color = PixelTheme.cardBackground,
        borderColor: Color = PixelTheme.border
    ) {
        self.thickness = thickness
        self.filled = filled
        self.fillColor = fillColor
        self.borderColor = borderColor
    }

    func body(content: Content) -> some View {
        content
            .padding(PixelScale.px(thickness + 1))
            .background(
                ZStack {
                    if filled {
                        PixelBorderShape(thickness: PixelScale.px(1))
                            .fill(fillColor)
                    }

                    // Draw border as overlapping rectangles for chunky pixel look
                    PixelBorderBackground(thickness: thickness, color: borderColor)
                }
            )
    }
}

// MARK: - Pixel Border Background

/// Creates the actual pixel border using overlapping rectangles
struct PixelBorderBackground: View {
    let thickness: Int
    let color: Color

    var body: some View {
        let t = PixelScale.px(thickness)

        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Top border
                Rectangle()
                    .fill(color)
                    .frame(width: w - t * 2, height: t)
                    .position(x: w / 2, y: t / 2)

                // Bottom border
                Rectangle()
                    .fill(color)
                    .frame(width: w - t * 2, height: t)
                    .position(x: w / 2, y: h - t / 2)

                // Left border
                Rectangle()
                    .fill(color)
                    .frame(width: t, height: h - t * 2)
                    .position(x: t / 2, y: h / 2)

                // Right border
                Rectangle()
                    .fill(color)
                    .frame(width: t, height: h - t * 2)
                    .position(x: w - t / 2, y: h / 2)

                // Corner pixels (for stepped look)
                // Top-left
                Rectangle()
                    .fill(color)
                    .frame(width: t, height: t)
                    .position(x: t + t / 2, y: t + t / 2)

                // Top-right
                Rectangle()
                    .fill(color)
                    .frame(width: t, height: t)
                    .position(x: w - t - t / 2, y: t + t / 2)

                // Bottom-left
                Rectangle()
                    .fill(color)
                    .frame(width: t, height: t)
                    .position(x: t + t / 2, y: h - t - t / 2)

                // Bottom-right
                Rectangle()
                    .fill(color)
                    .frame(width: t, height: t)
                    .position(x: w - t - t / 2, y: h - t - t / 2)
            }
        }
    }
}

// MARK: - Simple Pixel Border

/// A simpler pixel border using just rectangles (more performant)
struct SimplePixelBorder: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let t = PixelScale.px(1)

            // Outer border
            Rectangle()
                .stroke(color, lineWidth: t)
                .padding(t / 2)

            // Inner border for double-line effect
            Rectangle()
                .stroke(color, lineWidth: t)
                .padding(t * 1.5)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Adds a chunky pixel-art border around the view
    /// - Parameters:
    ///   - thickness: Border thickness in pixel units (default 2)
    ///   - filled: Whether to fill the background (default true)
    ///   - fillColor: Background fill color
    ///   - borderColor: Border stroke color
    func pixelBorder(
        thickness: Int = 2,
        filled: Bool = true,
        fillColor: Color = PixelTheme.cardBackground,
        borderColor: Color = PixelTheme.border
    ) -> some View {
        modifier(PixelBorderModifier(
            thickness: thickness,
            filled: filled,
            fillColor: fillColor,
            borderColor: borderColor
        ))
    }

    /// Adds a simple single-line pixel border
    func pixelOutline(color: Color = PixelTheme.border) -> some View {
        self.overlay(
            Rectangle()
                .stroke(color, lineWidth: PixelScale.px(1))
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("PIXEL BORDER")
            .font(.custom("Menlo-Bold", size: 14))
            .foregroundColor(PixelTheme.text)
            .pixelBorder()

        Text("THIN BORDER")
            .font(.custom("Menlo-Bold", size: 14))
            .foregroundColor(PixelTheme.text)
            .pixelBorder(thickness: 1)

        Text("OUTLINE ONLY")
            .font(.custom("Menlo-Bold", size: 14))
            .foregroundColor(PixelTheme.text)
            .padding(12)
            .pixelOutline()
    }
    .padding(40)
    .background(PixelTheme.background)
}
