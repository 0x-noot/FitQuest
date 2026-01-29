import Foundation
import SwiftData

class QuestManager {
    static let shared = QuestManager()
    private let questsPerDay = 3

    private init() {}

    // MARK: - Quest Generation

    func generateDailyQuests(excluding: [QuestType] = []) -> [DailyQuest] {
        var availableQuests = QuestType.allCases.filter { !excluding.contains($0) }
        var selectedQuests: [DailyQuest] = []

        // Try to get a mix of difficulties
        let difficulties: [QuestDifficulty] = [.easy, .medium, .hard]

        for difficulty in difficulties where selectedQuests.count < questsPerDay {
            let matchingQuests = availableQuests.filter { $0.difficulty == difficulty }
            if let quest = matchingQuests.randomElement() {
                selectedQuests.append(DailyQuest(questType: quest))
                availableQuests.removeAll { $0 == quest }
            }
        }

        // Fill remaining slots with random quests
        while selectedQuests.count < questsPerDay && !availableQuests.isEmpty {
            if let quest = availableQuests.randomElement() {
                selectedQuests.append(DailyQuest(questType: quest))
                availableQuests.removeAll { $0 == quest }
            }
        }

        return selectedQuests
    }

    func shouldRefreshQuests(lastRefresh: Date?) -> Bool {
        guard let lastRefresh = lastRefresh else { return true }

        let calendar = Calendar.current
        return !calendar.isDateInToday(lastRefresh)
    }

    // MARK: - Quest Progress

    func checkQuestCompletion(
        quest: DailyQuest,
        player: Player,
        workout: Workout? = nil
    ) -> Bool {
        guard !quest.isCompleted else { return false }

        switch quest.questType {
        case .earlyBird:
            // Check if workout was completed before 9 AM
            if let workout = workout {
                let hour = Calendar.current.component(.hour, from: workout.completedAt)
                if hour < 9 {
                    quest.markComplete()
                    return true
                }
            }

        case .nightOwl:
            // Check if workout was completed after 9 PM
            if let workout = workout {
                let hour = Calendar.current.component(.hour, from: workout.completedAt)
                if hour >= 21 {
                    quest.markComplete()
                    return true
                }
            }

        case .doubleDown:
            // Check if 2 workouts completed today
            if workout != nil {
                quest.incrementProgress()
                return quest.isCompleted
            }

        case .petCare:
            // Checked separately when treat is fed
            break

        case .strengthFocus:
            // Check if strength workout completed
            if let workout = workout, workout.workoutType == .strength {
                quest.markComplete()
                return true
            }

        case .cardioFocus:
            // Check if cardio workout completed
            if let workout = workout, workout.workoutType == .cardio {
                quest.markComplete()
                return true
            }

        case .streakKeeper:
            // Any workout completes this
            if workout != nil {
                quest.markComplete()
                return true
            }

        case .happyPet:
            // Check pet happiness
            if let pet = player.pet, pet.happiness >= 80 {
                quest.markComplete()
                return true
            }

        case .playTime:
            // Checked separately when playing with pet
            break
        }

        return false
    }

    func checkPetCareQuest(quest: DailyQuest) -> Bool {
        guard quest.questType == .petCare, !quest.isCompleted else { return false }
        quest.markComplete()
        return true
    }

    func checkPlayTimeQuest(quest: DailyQuest) -> Bool {
        guard quest.questType == .playTime, !quest.isCompleted else { return false }
        quest.markComplete()
        return true
    }

    func checkHappyPetQuest(quest: DailyQuest, pet: Pet) -> Bool {
        guard quest.questType == .happyPet, !quest.isCompleted else { return false }
        if pet.happiness >= 80 {
            quest.markComplete()
            return true
        }
        return false
    }

    // MARK: - Reward Distribution

    func claimReward(quest: DailyQuest, player: Player, pet: Pet?) {
        guard quest.isCompleted, !quest.isRewardClaimed else { return }

        switch quest.questType.rewardType {
        case .xp:
            pet?.addXP(quest.questType.rewardAmount)
        case .essence:
            player.essenceCurrency += quest.questType.rewardAmount
        }

        quest.isRewardClaimed = true
    }
}
