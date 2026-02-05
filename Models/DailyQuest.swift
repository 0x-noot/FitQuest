import Foundation
import SwiftData

@Model
final class DailyQuest {
    var id: UUID = UUID()
    var questTypeRaw: String = ""
    var progress: Int = 0
    var isCompleted: Bool = false
    var isRewardClaimed: Bool = false
    var createdAt: Date = Date()

    // Inverse relationship for CloudKit
    var player: Player?

    var questType: QuestType {
        get { QuestType(rawValue: questTypeRaw) ?? .streakKeeper }
        set { questTypeRaw = newValue.rawValue }
    }

    var progressPercent: Double {
        guard questType.target > 0 else { return 0 }
        return min(1.0, Double(progress) / Double(questType.target))
    }

    init(questType: QuestType) {
        self.id = UUID()
        self.questTypeRaw = questType.rawValue
        self.progress = 0
        self.isCompleted = false
        self.isRewardClaimed = false
        self.createdAt = Date()
    }

    func incrementProgress() {
        guard !isCompleted else { return }
        progress += 1
        if progress >= questType.target {
            isCompleted = true
        }
    }

    func markComplete() {
        progress = questType.target
        isCompleted = true
    }
}
