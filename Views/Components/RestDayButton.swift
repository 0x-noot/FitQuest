import SwiftUI

struct RestDayButton: View {
    @Bindable var player: Player
    @State private var showConfirmation = false
    @State private var showSuccess = false

    private var canUseRestDay: Bool {
        player.currentStreak > 0 &&
        !player.hasWorkedOutToday &&
        player.remainingRestDays > 0
    }

    var body: some View {
        VStack(spacing: PixelScale.px(1)) {
            Button {
                showConfirmation = true
            } label: {
                HStack(spacing: PixelScale.px(2)) {
                    PixelIconView(
                        icon: .moon,
                        size: 14,
                        color: canUseRestDay ? PixelTheme.gbLightest : PixelTheme.textSecondary
                    )

                    PixelText(
                        "REST DAY",
                        size: .small,
                        color: canUseRestDay ? PixelTheme.text : PixelTheme.textSecondary
                    )

                    PixelText(
                        "(\(player.remainingRestDays) LEFT)",
                        size: .small,
                        color: PixelTheme.textSecondary
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PixelScale.px(3))
                .padding(.vertical, PixelScale.px(2))
                .background(canUseRestDay ? PixelTheme.cardBackground : PixelTheme.gbDarkest)
                .pixelOutline(color: canUseRestDay ? PixelTheme.border : PixelTheme.gbDark)
            }
            .buttonStyle(.plain)
            .disabled(!canUseRestDay)

            if !canUseRestDay && player.currentStreak > 0 {
                if player.hasWorkedOutToday {
                    PixelText("ALREADY WORKED OUT!", size: .small, color: PixelTheme.textSecondary)
                } else if player.remainingRestDays == 0 {
                    PixelText("NO REST DAYS LEFT", size: .small, color: PixelTheme.textSecondary)
                }
            }
        }
        .alert("Use Rest Day?", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Use Rest Day") {
                useRestDay()
            }
        } message: {
            Text("This will protect your \(player.currentStreak)-day streak without requiring a workout today. You have \(player.remainingRestDays) rest day\(player.remainingRestDays == 1 ? "" : "s") remaining this week.")
        }
        .alert("Rest Day Used!", isPresented: $showSuccess) {
            Button("OK") { }
        } message: {
            Text("Your streak is protected! You have \(player.remainingRestDays) rest day\(player.remainingRestDays == 1 ? "" : "s") left this week.")
        }
    }

    private func useRestDay() {
        if player.soundEffectsEnabled {
            SoundManager.shared.playWarningHaptic()
        }

        if player.useRestDay() {
            showSuccess = true
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        RestDayButton(player: {
            let p = Player(name: "Test")
            p.currentStreak = 5
            return p
        }())

        RestDayButton(player: {
            let p = Player(name: "Test")
            p.currentStreak = 5
            p.lastWorkoutDate = Date()
            return p
        }())

        RestDayButton(player: {
            let p = Player(name: "Test")
            p.currentStreak = 0
            return p
        }())
    }
    .padding(PixelScale.px(4))
    .background(PixelTheme.background)
}
