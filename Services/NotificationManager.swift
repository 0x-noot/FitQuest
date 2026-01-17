import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private let notificationCenter = UNUserNotificationCenter.current()
    private let workoutReminderIdentifier = "fitquest.workout.reminder"

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
