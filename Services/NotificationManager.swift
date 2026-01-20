import Foundation
import UserNotifications
import SwiftUI
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private let notificationCenter = UNUserNotificationCenter.current()
    private let workoutReminderIdentifier = "fitquest.workout.reminder"
    private let petHungryIdentifier = "fitquest.pet.hungry"
    private let petSadIdentifier = "fitquest.pet.sad"
    private let petLeavingIdentifier = "fitquest.pet.leaving"

    override init() {
        super.init()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Scheduling

    /// Schedule daily workout reminder at 1 PM
    func scheduleDailyReminder() {
        // First remove any existing reminder
        cancelDailyReminder()

        // Create content
        let content = UNMutableNotificationContent()
        content.title = "Time to Work Out!"
        content.body = getRandomReminderMessage()
        content.sound = .default
        content.badge = 1

        // Schedule for 1 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 13  // 1 PM
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: workoutReminderIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    /// Cancel the daily reminder
    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [workoutReminderIdentifier])
    }

    /// Cancel today's notification if user has already worked out
    func cancelTodayReminderIfWorkedOut(hasWorkedOutToday: Bool) {
        guard hasWorkedOutToday else { return }

        // Get pending notifications and remove today's if it exists
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }

            // The calendar trigger will fire again tomorrow, so we just need to
            // make sure we don't show it today. We can do this by checking
            // delivered notifications and removing them.
            self.notificationCenter.removeDeliveredNotifications(withIdentifiers: [self.workoutReminderIdentifier])
        }

        // Clear badge
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Pet Notifications

    /// Schedule pet notifications based on happiness level
    func schedulePetNotifications(for pet: Pet) {
        // Cancel existing pet notifications first
        cancelPetNotifications()

        guard !pet.isAway else { return }

        let petName = pet.name

        // Schedule notifications based on happiness level
        if pet.happiness < 30 {
            // Critical: 8 PM urgent notification
            schedulePetNotification(
                identifier: petSadIdentifier,
                title: "\(petName) needs you!",
                body: "Happiness critical! Your \(pet.species.displayName) might leave soon. Feed a treat or work out!",
                hour: 20,  // 8 PM
                minute: 0
            )
        } else if pet.happiness < 50 {
            // Warning: 6 PM notification
            schedulePetNotification(
                identifier: petHungryIdentifier,
                title: "\(petName) is getting sad",
                body: "Your \(pet.species.displayName) needs attention. Feed them a treat or work out to boost happiness!",
                hour: 18,  // 6 PM
                minute: 0
            )
        }
    }

    /// Schedule immediate notification when pet runs away
    func schedulePetLeavingNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Your pet ran away!"
        content.body = "Your pet's happiness hit 0%. Complete 3 workouts in 7 days or pay 150 Essence to bring them back."
        content.sound = .default
        content.badge = 1

        // Immediate trigger (5 seconds delay to ensure it shows)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: petLeavingIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling pet leaving notification: \(error)")
            }
        }
    }

    /// Cancel all pet notifications
    func cancelPetNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            petHungryIdentifier,
            petSadIdentifier,
            petLeavingIdentifier
        ])
    }

    /// Cancel today's pet notifications (called after workout or treat)
    func cancelTodayPetNotifications() {
        // Remove pending notifications
        cancelPetNotifications()

        // Remove delivered notifications
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [
            petHungryIdentifier,
            petSadIdentifier,
            petLeavingIdentifier
        ])
    }

    // MARK: - Private Pet Notification Helper

    private func schedulePetNotification(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling pet notification (\(identifier)): \(error)")
            }
        }
    }

    // MARK: - Helper Methods

    private func getRandomReminderMessage() -> String {
        let messages = [
            "Your streak is waiting! Time to level up.",
            "Don't break your streak! A quick workout awaits.",
            "Ready to earn some XP? Let's get moving!",
            "Your character is getting restless. Time for a workout!",
            "Level up your fitness game today!",
            "A workout a day keeps the streak decay away!",
            "Your future self will thank you. Let's go!",
            "Time to add another workout to your quest!",
            "Every rep counts towards your next level!",
            "Your streak is calling. Answer with gains!"
        ]
        return messages.randomElement() ?? messages[0]
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap - could navigate to home tab
        completionHandler()
    }
}
