import Foundation
import SwiftData

struct PetManager {

    // MARK: - Constants

    /// Passive decay rate: 33.33% per day (pet runs away after 3 days)
    static let passiveDecayPerDay: Double = 33.33

    /// Workout happiness boost
    static let workoutHappinessBoost: Double = 15.0

    /// Essence earning rate (1 essence per 10 XP)
    static let essencePerXP: Int = 10

    /// Recovery cost when pet runs away
    static let essenceRecoveryCost: Int = 150

    /// Recovery happiness level
    static let recoveryHappiness: Double = 50.0

    // MARK: - Passive Happiness Decay

    /// Apply passive decay based on time elapsed
    static func applyPassiveDecay(pet: Pet) {
        let now = Date()
        let hoursSince = now.timeIntervalSince(pet.lastHappinessUpdateDate) / 3600.0  // Convert seconds to hours

        // Calculate decay: 33.33% per 24 hours = 1.3888% per hour
        let decayAmount = (hoursSince / 24.0) * passiveDecayPerDay

        // Apply decay
        modifyHappiness(pet: pet, amount: -decayAmount)

        // Update last check date
        pet.lastHappinessUpdateDate = now
    }

    // MARK: - Happiness Modification

    /// Modify happiness and clamp to 0-100 range
    static func modifyHappiness(pet: Pet, amount: Double) {
        pet.happiness += amount
        pet.happiness = max(0, min(100, pet.happiness))

        // Trigger pet running away if happiness hits 0
        if pet.happiness <= 0 && !pet.isAway {
            pet.isAway = true
            pet.awayDate = Date()

            // Schedule notification that pet has left
            NotificationManager.shared.schedulePetLeavingNotification()
        }
    }

    /// Add happiness from workout completion
    static func onWorkoutComplete(pet: Pet) {
        guard !pet.isAway else { return }
        modifyHappiness(pet: pet, amount: workoutHappinessBoost)
    }

    /// Feed treat to pet
    static func feedTreat(pet: Pet, treat: PetTreat, player: Player) -> Bool {
        guard !pet.isAway else { return false }
        guard player.essenceCurrency >= treat.essenceCost else { return false }

        // Deduct essence
        player.essenceCurrency -= treat.essenceCost

        // Add happiness
        modifyHappiness(pet: pet, amount: treat.happinessBoost)

        // Update last happiness date (reset decay timer)
        pet.lastHappinessUpdateDate = Date()

        return true
    }

    // MARK: - Recovery System

    /// Check if pet can be recovered with workouts (3 in last 7 days)
    static func canRecoverWithWorkouts(pet: Pet, player: Player) -> Bool {
        guard pet.isAway else { return false }

        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        let recentWorkouts = (player.workouts ?? []).filter { $0.completedAt >= sevenDaysAgo }

        return recentWorkouts.count >= 3
    }

    /// Recover pet using workouts
    static func recoverPetWithWorkouts(pet: Pet) -> Bool {
        guard pet.isAway else { return false }

        pet.isAway = false
        pet.awayDate = nil
        pet.happiness = recoveryHappiness
        pet.lastHappinessUpdateDate = Date()

        return true
    }

    /// Check if pet can be recovered with essence
    static func canRecoverWithEssence(pet: Pet, player: Player) -> Bool {
        guard pet.isAway else { return false }
        return player.essenceCurrency >= essenceRecoveryCost
    }

    /// Recover pet using essence
    static func recoverPetWithEssence(pet: Pet, player: Player) -> Bool {
        guard canRecoverWithEssence(pet: pet, player: player) else { return false }

        player.essenceCurrency -= essenceRecoveryCost
        pet.isAway = false
        pet.awayDate = nil
        pet.happiness = recoveryHappiness
        pet.lastHappinessUpdateDate = Date()

        return true
    }

    // MARK: - Play Interaction System

    /// Reset play sessions if it's a new day
    static func resetPlaySessionsIfNeeded(pet: Pet) {
        guard let lastPlay = pet.lastPlayDate else { return }
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastPlay) {
            pet.playSessionsToday = 0
            pet.tapCount = 0
        }
    }

    /// Handle a tap on the pet. Returns the result of the tap.
    static func handlePetTap(pet: Pet) -> PetTapResult {
        guard !pet.isAway else { return .petIsAway }

        resetPlaySessionsIfNeeded(pet: pet)

        guard pet.playSessionsToday < Pet.maxPlaySessionsPerDay else {
            return .noSessionsRemaining
        }

        // Increment tap count
        pet.tapCount += 1

        // Check if we've completed a play session
        if pet.tapCount >= Pet.tapsPerSession {
            // Complete the session
            pet.tapCount = 0
            pet.playSessionsToday += 1
            pet.lastPlayDate = Date()

            // Add happiness
            modifyHappiness(pet: pet, amount: Pet.happinessPerSession)

            return .sessionComplete(sessionsRemaining: Pet.maxPlaySessionsPerDay - pet.playSessionsToday)
        }

        return .tapRegistered(tapsRemaining: Pet.tapsPerSession - pet.tapCount)
    }

    // MARK: - Utility

    /// Calculate essence earned from workout XP
    static func essenceEarnedForWorkout(xp: Int) -> Int {
        xp / essencePerXP
    }

    /// Get happiness XP multiplier (1.10 if >= 90%, else 1.0)
    static func happinessXPMultiplier(happiness: Double) -> Double {
        happiness >= 90.0 ? 1.10 : 1.0
    }

    /// Check if pet has XP bonus active
    static func hasXPBonus(happiness: Double) -> Bool {
        happiness >= 90.0
    }
}

// MARK: - Pet Tap Result

enum PetTapResult {
    case tapRegistered(tapsRemaining: Int)
    case sessionComplete(sessionsRemaining: Int)
    case noSessionsRemaining
    case petIsAway
}
