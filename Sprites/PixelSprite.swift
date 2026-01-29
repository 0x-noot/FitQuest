import SwiftUI

// MARK: - Pixel Shade

/// Represents a single pixel's shade in the 4-color Game Boy palette
enum PixelShade: Int {
    case transparent = 0
    case lightest = 1    // gbLightest - highlights
    case light = 2       // gbLight - base/fill
    case dark = 3        // gbDark - shadows
    case darkest = 4     // gbDarkest - outlines

    var color: Color {
        switch self {
        case .transparent: return .clear
        case .lightest: return PixelTheme.gbLightest
        case .light: return PixelTheme.gbLight
        case .dark: return PixelTheme.gbDark
        case .darkest: return PixelTheme.gbDarkest
        }
    }

    /// Short alias for sprite data entry
    static let t = PixelShade.transparent
    static let L = PixelShade.lightest
    static let l = PixelShade.light
    static let d = PixelShade.dark
    static let D = PixelShade.darkest
}

// MARK: - Pixel Sprite

/// A 2D grid of pixel shades that can be rendered as pixel art
struct PixelSprite {
    let width: Int
    let height: Int
    let pixels: [[PixelShade]]

    init(width: Int, height: Int, pixels: [[PixelShade]]) {
        self.width = width
        self.height = height
        self.pixels = pixels
    }

    /// Create a sprite from raw integer data (0-4)
    init(width: Int, height: Int, data: [[Int]]) {
        self.width = width
        self.height = height
        self.pixels = data.map { row in
            row.map { PixelShade(rawValue: $0) ?? .transparent }
        }
    }

    /// Get the shade at a specific position
    func shade(at row: Int, col: Int) -> PixelShade {
        guard row >= 0 && row < height && col >= 0 && col < width else {
            return .transparent
        }
        return pixels[row][col]
    }
}

// MARK: - Animation Frame

/// A single frame in a sprite animation
struct SpriteAnimationFrame {
    let sprite: PixelSprite
    let yOffset: CGFloat
    let xOffset: CGFloat

    init(sprite: PixelSprite, yOffset: CGFloat = 0, xOffset: CGFloat = 0) {
        self.sprite = sprite
        self.yOffset = yOffset
        self.xOffset = xOffset
    }
}

// MARK: - Sprite Animation

/// A collection of frames for animating a sprite
struct SpriteAnimation {
    let frames: [SpriteAnimationFrame]
    let frameDuration: Double  // Seconds per frame

    init(frames: [SpriteAnimationFrame], frameDuration: Double) {
        self.frames = frames
        self.frameDuration = frameDuration
    }

    /// Create a simple bounce animation from a single sprite
    static func bounce(sprite: PixelSprite, amount: CGFloat, frameDuration: Double) -> SpriteAnimation {
        let frames = [
            SpriteAnimationFrame(sprite: sprite, yOffset: 0),
            SpriteAnimationFrame(sprite: sprite, yOffset: -amount),
            SpriteAnimationFrame(sprite: sprite, yOffset: 0),
            SpriteAnimationFrame(sprite: sprite, yOffset: amount * 0.5),
        ]
        return SpriteAnimation(frames: frames, frameDuration: frameDuration)
    }

    /// Create a gentle bob animation
    static func bob(sprite: PixelSprite, amount: CGFloat, frameDuration: Double) -> SpriteAnimation {
        let frames = [
            SpriteAnimationFrame(sprite: sprite, yOffset: 0),
            SpriteAnimationFrame(sprite: sprite, yOffset: -amount),
        ]
        return SpriteAnimation(frames: frames, frameDuration: frameDuration)
    }

    /// Create a shiver/shake animation
    static func shiver(sprite: PixelSprite, amount: CGFloat, frameDuration: Double) -> SpriteAnimation {
        let frames = [
            SpriteAnimationFrame(sprite: sprite, xOffset: -amount),
            SpriteAnimationFrame(sprite: sprite, xOffset: amount),
        ]
        return SpriteAnimation(frames: frames, frameDuration: frameDuration)
    }

    /// Create a droop animation
    static func droop(sprite: PixelSprite, amount: CGFloat, frameDuration: Double) -> SpriteAnimation {
        let frames = [
            SpriteAnimationFrame(sprite: sprite, yOffset: 0),
            SpriteAnimationFrame(sprite: sprite, yOffset: amount),
        ]
        return SpriteAnimation(frames: frames, frameDuration: frameDuration)
    }
}

// MARK: - Pixel Sprite View

/// Renders a PixelSprite at the specified pixel size
struct PixelSpriteView: View {
    let sprite: PixelSprite
    let pixelSize: CGFloat

    var body: some View {
        Canvas { context, _ in
            for row in 0..<sprite.height {
                for col in 0..<sprite.width {
                    let shade = sprite.pixels[row][col]
                    if shade != .transparent {
                        let rect = CGRect(
                            x: CGFloat(col) * pixelSize,
                            y: CGFloat(row) * pixelSize,
                            width: pixelSize,
                            height: pixelSize
                        )
                        context.fill(Path(rect), with: .color(shade.color))
                    }
                }
            }
        }
        .frame(
            width: CGFloat(sprite.width) * pixelSize,
            height: CGFloat(sprite.height) * pixelSize
        )
    }
}

// MARK: - Animated Sprite View

/// Renders an animated sprite with frame-based stepping
struct AnimatedSpriteView: View {
    let animation: SpriteAnimation
    let pixelSize: CGFloat
    let isAnimating: Bool

    @State private var frameIndex = 0
    @State private var timer: Timer?

    var body: some View {
        let frame = animation.frames[frameIndex]

        PixelSpriteView(sprite: frame.sprite, pixelSize: pixelSize)
            .offset(x: frame.xOffset * pixelSize, y: frame.yOffset * pixelSize)
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
            .onChange(of: isAnimating) { _, newValue in
                if newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
    }

    private func startAnimation() {
        guard isAnimating else { return }
        stopAnimation()

        timer = Timer.scheduledTimer(withTimeInterval: animation.frameDuration, repeats: true) { _ in
            frameIndex = (frameIndex + 1) % animation.frames.count
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
        frameIndex = 0
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Test sprite (simple 8x8 smiley)
        let testSprite = PixelSprite(width: 8, height: 8, data: [
            [0,0,4,4,4,4,0,0],
            [0,4,2,2,2,2,4,0],
            [4,2,4,2,2,4,2,4],
            [4,2,2,2,2,2,2,4],
            [4,2,4,2,2,4,2,4],
            [4,2,2,4,4,2,2,4],
            [0,4,2,2,2,2,4,0],
            [0,0,4,4,4,4,0,0],
        ])

        PixelSpriteView(sprite: testSprite, pixelSize: 8)

        AnimatedSpriteView(
            animation: .bounce(sprite: testSprite, amount: 2, frameDuration: 0.2),
            pixelSize: 6,
            isAnimating: true
        )
    }
    .padding(40)
    .background(PixelTheme.background)
}
