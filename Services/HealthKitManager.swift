import Combine
import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)

    @Published var todaySteps: Int = 0
    @Published var authorizationStatus: AuthStatus = .notDetermined
    @Published var isLoading: Bool = false

    enum AuthStatus {
        case notDetermined
        case authorized
        case denied
        case unavailable
    }

    // MARK: - Step XP Constants

    /// XP awarded per 1,000 steps
    static let xpPer1000Steps: Int = 10

    /// Maximum step XP per day (caps at 20,000 steps)
    static let maxDailyStepXP: Int = 200

    /// Daily step goal for UI display
    static let dailyStepGoal: Int = 10000

    private init() {
        if !HKHealthStore.isHealthDataAvailable() {
            authorizationStatus = .unavailable
        }
    }

    // MARK: - Authorization

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async {
        guard isAvailable else {
            await MainActor.run { authorizationStatus = .unavailable }
            return
        }

        let typesToRead: Set<HKObjectType> = [stepType]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            // HealthKit does not reveal read authorization status for privacy.
            // After requesting, we optimistically treat it as authorized.
            await MainActor.run { authorizationStatus = .authorized }
        } catch {
            await MainActor.run { authorizationStatus = .denied }
        }
    }

    // MARK: - Step Fetching

    /// Attempt to fetch steps on launch to infer authorization status.
    /// HealthKit remembers OS-level permissions, so a successful fetch means authorized.
    func checkAndFetchSteps() async {
        guard isAvailable else {
            await MainActor.run { authorizationStatus = .unavailable }
            return
        }

        await MainActor.run { isLoading = true }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let samplePredicate = HKSamplePredicate.quantitySample(
            type: stepType,
            predicate: predicate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum
        )

        do {
            let result = try await descriptor.result(for: healthStore)
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0

            await MainActor.run {
                self.todaySteps = Int(steps)
                self.authorizationStatus = .authorized
                self.isLoading = false
            }
            startObservingSteps()
        } catch {
            await MainActor.run {
                self.authorizationStatus = .notDetermined
                self.isLoading = false
            }
        }
    }

    func fetchTodaySteps() async {
        guard isAvailable else { return }

        await MainActor.run { isLoading = true }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let samplePredicate = HKSamplePredicate.quantitySample(
            type: stepType,
            predicate: predicate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum
        )

        do {
            let result = try await descriptor.result(for: healthStore)
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0

            await MainActor.run {
                self.todaySteps = Int(steps)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    func startObservingSteps() {
        guard isAvailable else { return }

        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, _ in
            Task {
                await self?.fetchTodaySteps()
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Step XP Calculation

    /// Calculate XP earned for a given step count
    static func calculateStepXP(steps: Int) -> Int {
        let rawXP = (steps / 1000) * xpPer1000Steps
        return min(rawXP, maxDailyStepXP)
    }

    /// Award step XP based on current HealthKit steps, returns XP awarded
    static func awardStepXP(player: Player, pet: Pet?, currentSteps: Int) -> Int {
        let calendar = Calendar.current

        // Calculate total possible XP for current steps
        let totalXPForAllSteps = calculateStepXP(steps: currentSteps)

        // Calculate how much XP was already awarded today
        let alreadyAwardedXP: Int
        if let lastDate = player.lastStepXPAwardDate,
           calendar.isDateInToday(lastDate) {
            alreadyAwardedXP = calculateStepXP(steps: player.lastStepXPAwardedSteps)
        } else {
            alreadyAwardedXP = 0
        }

        let xpToAward = max(0, totalXPForAllSteps - alreadyAwardedXP)
        guard xpToAward > 0 else { return 0 }

        // Award XP to pet
        pet?.addXP(xpToAward)

        // Award essence
        let essenceEarned = PetManager.essenceEarnedForWorkout(xp: xpToAward)
        player.essenceCurrency += essenceEarned

        // Update tracking
        player.lastStepXPAwardDate = Date()
        player.lastStepXPAwardedSteps = currentSteps

        return xpToAward
    }
}
