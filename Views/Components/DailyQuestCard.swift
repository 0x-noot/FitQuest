import SwiftUI

// MARK: - Legacy Quest Card
// NOTE: This component is deprecated and not used in the app.
// The app uses PixelQuestRow from PixelCheckbox.swift instead.
// Kept for reference only.

struct DailyQuestCard: View {
    let quest: DailyQuest
    let onClaim: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Quest icon
            ZStack {
                Circle()
                    .fill(quest.questType.color.opacity(quest.isCompleted ? 0.3 : 0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: quest.questType.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(quest.isCompleted ? quest.questType.color : quest.questType.color.opacity(0.8))
            }

            // Quest info
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.questType.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(quest.isCompleted ? Theme.textSecondary : Theme.textPrimary)
                    .strikethrough(quest.isRewardClaimed)

                Text(quest.questType.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textMuted)
                    .lineLimit(1)

                // Progress bar (for multi-step quests)
                if quest.questType.target > 1 && !quest.isCompleted {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Theme.elevated)
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(quest.questType.color)
                                .frame(width: geometry.size.width * quest.progressPercent, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.top, 2)
                }
            }

            Spacer()

            // Reward & status
            VStack(alignment: .trailing, spacing: 4) {
                if quest.isRewardClaimed {
                    // Claimed checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.success)
                } else if quest.isCompleted {
                    // Claim button
                    Button(action: onClaim) {
                        Text("Claim")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(quest.questType.color)
                            .cornerRadius(8)
                    }
                } else {
                    // Reward preview
                    HStack(spacing: 4) {
                        Image(systemName: quest.questType.rewardType.iconName)
                            .font(.system(size: 12))
                        Text("+\(quest.questType.rewardAmount)")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(quest.questType.rewardType.color)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(quest.isRewardClaimed ? Theme.cardBackground.opacity(0.5) : Theme.cardBackground)
        )
        .opacity(quest.isRewardClaimed ? 0.7 : 1.0)
    }
}

struct DailyQuestsSection: View {
    let quests: [DailyQuest]
    let onClaimReward: (DailyQuest) -> Void

    var completedCount: Int {
        quests.filter { $0.isCompleted }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.warning)

                Text("Daily Quests")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                Text("\(completedCount)/\(quests.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.textSecondary)
            }

            // Quest cards
            ForEach(quests, id: \.id) { quest in
                DailyQuestCard(quest: quest) {
                    onClaimReward(quest)
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    VStack(spacing: 20) {
        // In progress quest
        DailyQuestCard(
            quest: {
                let q = DailyQuest(questType: .doubleDown)
                q.progress = 1
                return q
            }(),
            onClaim: {}
        )

        // Completed quest (unclaimed)
        DailyQuestCard(
            quest: {
                let q = DailyQuest(questType: .earlyBird)
                q.isCompleted = true
                return q
            }(),
            onClaim: {}
        )

        // Claimed quest
        DailyQuestCard(
            quest: {
                let q = DailyQuest(questType: .streakKeeper)
                q.isCompleted = true
                q.isRewardClaimed = true
                return q
            }(),
            onClaim: {}
        )

        // Full section
        DailyQuestsSection(
            quests: [
                DailyQuest(questType: .earlyBird),
                {
                    let q = DailyQuest(questType: .petCare)
                    q.isCompleted = true
                    return q
                }(),
                {
                    let q = DailyQuest(questType: .streakKeeper)
                    q.isCompleted = true
                    q.isRewardClaimed = true
                    return q
                }()
            ],
            onClaimReward: { _ in }
        )
    }
    .padding()
    .background(Theme.background)
    .preferredColorScheme(.dark)
}
