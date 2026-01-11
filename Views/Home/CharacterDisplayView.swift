import SwiftUI

struct CharacterDisplayView: View {
    let appearance: CharacterAppearance
    var size: CGFloat = 150
    var showShadow: Bool = true

    @State private var breatheAnimation = false

    var body: some View {
        ZStack {
            // Shadow
            if showShadow {
                Ellipse()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: size * 0.5, height: size * 0.15)
                    .offset(y: size * 0.42)
            }

            // Character body
            VStack(spacing: 0) {
                // Head + Hair
                ZStack {
                    // Hair back layer
                    hairShape
                        .fill(appearance.currentHairColor)
                        .frame(width: size * 0.4, height: size * 0.25)
                        .offset(y: -size * 0.02)

                    // Face
                    RoundedRectangle(cornerRadius: size * 0.08)
                        .fill(appearance.skinColor)
                        .frame(width: size * 0.35, height: size * 0.3)

                    // Eyes
                    HStack(spacing: size * 0.08) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.04, height: size * 0.04)
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.04, height: size * 0.04)
                    }
                    .offset(y: -size * 0.02)

                    // Hair front layer
                    hairFrontShape
                        .fill(appearance.currentHairColor)
                        .frame(width: size * 0.38, height: size * 0.12)
                        .offset(y: -size * 0.12)

                    // Headwear (if equipped)
                    if let _ = appearance.headwear {
                        headwearView
                    }
                }

                // Body/Torso
                ZStack {
                    // Torso
                    RoundedRectangle(cornerRadius: size * 0.06)
                        .fill(appearance.topColor)
                        .frame(width: size * 0.4, height: size * 0.35)

                    // Arms
                    HStack(spacing: size * 0.32) {
                        RoundedRectangle(cornerRadius: size * 0.03)
                            .fill(appearance.skinColor)
                            .frame(width: size * 0.08, height: size * 0.2)
                        RoundedRectangle(cornerRadius: size * 0.03)
                            .fill(appearance.skinColor)
                            .frame(width: size * 0.08, height: size * 0.2)
                    }
                    .offset(y: size * 0.02)
                }
                .offset(y: -size * 0.02)

                // Legs
                HStack(spacing: size * 0.04) {
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(appearance.bottomColor)
                        .frame(width: size * 0.14, height: size * 0.22)
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(appearance.bottomColor)
                        .frame(width: size * 0.14, height: size * 0.22)
                }
                .offset(y: -size * 0.04)

                // Feet
                HStack(spacing: size * 0.06) {
                    RoundedRectangle(cornerRadius: size * 0.02)
                        .fill(Color(hex: "333333"))
                        .frame(width: size * 0.12, height: size * 0.05)
                    RoundedRectangle(cornerRadius: size * 0.02)
                        .fill(Color(hex: "333333"))
                        .frame(width: size * 0.12, height: size * 0.05)
                }
                .offset(y: -size * 0.05)
            }
            .scaleEffect(breatheAnimation ? 1.02 : 1.0)
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: breatheAnimation
            )
        }
        .frame(width: size, height: size)
        .onAppear {
            breatheAnimation = true
        }
    }

    private var hairShape: some Shape {
        RoundedRectangle(cornerRadius: size * 0.1)
    }

    private var hairFrontShape: some Shape {
        switch appearance.hairStyle {
        case 0:
            return AnyShape(RoundedRectangle(cornerRadius: size * 0.03))
        case 1:
            return AnyShape(Capsule())
        case 2:
            return AnyShape(UnevenRoundedRectangle(
                topLeadingRadius: size * 0.06,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: size * 0.06
            ))
        default:
            return AnyShape(RoundedRectangle(cornerRadius: size * 0.04))
        }
    }

    @ViewBuilder
    private var headwearView: some View {
        // Simple cap placeholder
        RoundedRectangle(cornerRadius: size * 0.04)
            .fill(Theme.primary)
            .frame(width: size * 0.42, height: size * 0.08)
            .offset(y: -size * 0.16)
    }
}

// Helper for dynamic shapes
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        _path = { rect in
            wrapped.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

#Preview {
    VStack(spacing: 30) {
        CharacterDisplayView(appearance: CharacterAppearance(), size: 150)
        CharacterDisplayView(appearance: {
            let c = CharacterAppearance()
            c.skinTone = 3
            c.hairColor = 2
            c.top = 1
            c.bottom = 2
            return c
        }(), size: 120)
    }
    .padding()
    .background(Theme.background)
}
