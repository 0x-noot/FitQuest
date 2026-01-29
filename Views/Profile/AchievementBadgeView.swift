import SwiftUI

struct AchievementBadgeView: View {
    let achievement: Achievement
    let isEarned: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(isEarned ? achievement.color.opacity(0.2) : Theme.elevated)
                    .frame(width: 56, height: 56)

                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isEarned ? achievement.color : Theme.textMuted)

                if !isEarned {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 56, height: 56)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)
                }
            }

            // Name
            Text(achievement.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isEarned ? Theme.textPrimary : Theme.textMuted)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    let isEarned: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Badge
            ZStack {
                Circle()
                    .fill(isEarned ? achievement.color.opacity(0.2) : Theme.elevated)
                    .frame(width: 100, height: 100)

                Image(systemName: achievement.icon)
                    .font(.system(size: 44))
                    .foregroundColor(isEarned ? achievement.color : Theme.textMuted)

                if !isEarned {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 100, height: 100)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.textMuted)
                }
            }

            VStack(spacing: 8) {
                Text(achievement.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isEarned ? Theme.textPrimary : Theme.textMuted)

                Text(achievement.description)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)

                if isEarned {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text("Earned")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Theme.success)
                    .padding(.top, 8)
                } else {
                    Text("Keep going to unlock!")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textMuted)
                        .padding(.top, 8)
                }
            }

            Spacer()

            Button("Close") {
                dismiss()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Theme.primary)
            .padding(.bottom, 20)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Theme.cardBackground)
    }
}

struct AchievementsSection: View {
    let player: Player
    @State private var selectedAchievement: Achievement?

    private var earnedCount: Int {
        Achievement.all.filter { $0.isEarned(player) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ACHIEVEMENTS")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textMuted)
                    .tracking(1)

                Spacer()

                Text("\(earnedCount)/\(Achievement.all.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(Achievement.all) { achievement in
                    Button {
                        selectedAchievement = achievement
                    } label: {
                        AchievementBadgeView(
                            achievement: achievement,
                            isEarned: achievement.isEarned(player)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(12)
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailView(
                achievement: achievement,
                isEarned: achievement.isEarned(player)
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ScrollView {
        AchievementsSection(player: {
            let player = Player(name: "Test")
            player.currentStreak = 7
            player.highestStreak = 14
            let pet = Pet(name: "Ember", species: .dragon)
            pet.totalXP = 5000
            player.pet = pet
            return player
        }())
            .padding()
    }
    .background(Color(red: 0.05, green: 0.05, blue: 0.06))
}
