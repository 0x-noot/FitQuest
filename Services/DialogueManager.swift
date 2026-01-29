import Foundation

class DialogueManager {
    static let shared = DialogueManager()

    private var lastDialogueTime: Date?
    private var lastDialogueContext: DialogueContext?

    // Minimum time between idle dialogues (in seconds)
    private let idleCooldown: TimeInterval = 30

    private init() {}

    func getDialogue(for pet: Pet, context: DialogueContext) -> String? {
        let dialogues = pet.species.dialogues(for: context, mood: pet.mood)

        guard !dialogues.isEmpty else { return nil }

        // For idle context, check cooldown
        if context == .idle {
            if let lastTime = lastDialogueTime,
               lastDialogueContext == .idle,
               Date().timeIntervalSince(lastTime) < idleCooldown {
                return nil
            }
        }

        let selectedDialogue = dialogues.randomElement()

        lastDialogueTime = Date()
        lastDialogueContext = context

        return selectedDialogue
    }

    func getGreetingDialogue(for pet: Pet) -> String? {
        // Determine if we should show happiness-related dialogue instead
        if pet.happiness < 30 {
            return getDialogue(for: pet, context: .lowHappiness)
        } else if pet.happiness >= 90 {
            return getDialogue(for: pet, context: .highHappiness)
        }

        return getDialogue(for: pet, context: .greeting)
    }

    func shouldShowIdleDialogue() -> Bool {
        guard let lastTime = lastDialogueTime else { return true }
        return Date().timeIntervalSince(lastTime) >= idleCooldown
    }

    func resetCooldown() {
        lastDialogueTime = nil
        lastDialogueContext = nil
    }
}
