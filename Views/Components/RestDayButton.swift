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
        VStack(spacing: 8) {
            Button {
                showConfirmation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 14))

                    Text("Use Rest Day")
                        .font(.system(size: 14, weight: .medium))

                    Text("(\(player.remainingRestDays) left)")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textMuted)
                }
                .foregroundColor(canUseRestDay ? Theme.secondary : Theme.textMuted)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(canUseRestDay ? Theme.secondary.opacity(0.15) : Theme.elevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(canUseRestDay ? Theme.secondary.opacity(0.3) : Theme.elevated, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!canUseRestDay)

            if !canUseRestDay && player.currentStreak > 0 {
                if player.hasWorkedOutToday {
                    Text("You've already worked out today!")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.success)
                } else if player.remainingRestDays == 0 {
                    Text("No rest days left this week")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textMuted)
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
        // Has streak, hasn't worked out
        RestDayButton(player: {
            let p = Player(name: "Test")
            p.currentStreak = 5
            return p
        }())

        // Has streak, already worked out
        RestDayButton(player: {
            let p = Player(name: "Test")
            p.currentStreak = 5
            p.lastWorkoutDate = Date()
            return p
        }())

        // No streak
        RestDayButton(player: {
            let p = Player(name: "Test")
            p.currentStreak = 0
            return p
        }())
    }
    .padding()
    .background(Color(red: 0.05, green: 0.05, blue: 0.06))
}
