import Foundation
import UserNotifications
import SwiftUI
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private let notificationCenter = UNUserNotificationCenter.current()

    // Guilt-based notification identifiers (Duolingo-style)
    private let morningGuiltIdentifier = "fitogatchi.guilt.morning"      // 9 AM
    private let afternoonGuiltIdentifier = "fitogatchi.guilt.afternoon"  // 3 PM

    // Legacy identifier for backward compatibility
    private let workoutReminderIdentifier = "fitogatchi.workout.reminder"

    // Pet notification identifiers
    private let petHungryIdentifier = "fitogatchi.pet.hungry"
    private let petSadIdentifier = "fitogatchi.pet.sad"
    private let petLeavingIdentifier = "fitogatchi.pet.leaving"

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

    // MARK: - Guilt-Based Workout Reminders (Duolingo-style)

    /// Schedule guilt notifications for morning (9 AM) and afternoon (3 PM)
    /// Only sends if user hasn't worked out - cancelled when workout is logged
    func scheduleGuiltReminders(pet: Pet) {
        // Cancel any existing guilt reminders first
        cancelGuiltReminders()

        guard !pet.isAway else { return }

        // Schedule morning guilt (9 AM)
        scheduleGuiltNotification(
            identifier: morningGuiltIdentifier,
            pet: pet,
            hour: 9,
            minute: 0,
            timeOfDay: .morning
        )

        // Schedule afternoon guilt (3 PM)
        scheduleGuiltNotification(
            identifier: afternoonGuiltIdentifier,
            pet: pet,
            hour: 15,
            minute: 0,
            timeOfDay: .afternoon
        )
    }

    private func scheduleGuiltNotification(
        identifier: String,
        pet: Pet,
        hour: Int,
        minute: Int,
        timeOfDay: GuiltNotificationMessages.TimeOfDay
    ) {
        let message = GuiltNotificationMessages.getGuiltMessage(
            petName: pet.name,
            species: pet.species,
            mood: pet.mood,
            timeOfDay: timeOfDay
        )

        let content = UNMutableNotificationContent()
        content.title = message.title
        content.body = message.body
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
                print("Error scheduling guilt notification (\(identifier)): \(error)")
            }
        }
    }

    /// Cancel both guilt reminders
    func cancelGuiltReminders() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            morningGuiltIdentifier,
            afternoonGuiltIdentifier,
            workoutReminderIdentifier  // Also cancel legacy identifier
        ])
    }

    /// Cancel today's guilt notifications after workout completion
    func cancelTodayGuiltNotifications() {
        // Remove pending (not yet delivered)
        cancelGuiltReminders()

        // Remove already delivered
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [
            morningGuiltIdentifier,
            afternoonGuiltIdentifier,
            workoutReminderIdentifier
        ])

        // Clear badge
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    /// Refresh guilt notifications with current pet state
    /// Call this when pet mood changes or app becomes active
    func refreshGuiltNotifications(pet: Pet, hasWorkedOutToday: Bool) {
        guard !hasWorkedOutToday else {
            cancelTodayGuiltNotifications()
            return
        }

        // Re-schedule with current pet mood for updated messaging
        scheduleGuiltReminders(pet: pet)
    }

    // MARK: - Legacy Methods (Backward Compatibility)

    /// Schedule daily workout reminder - now schedules guilt reminders instead
    func scheduleDailyReminder() {
        // Legacy method - guilt reminders require pet context
        // This is kept for backward compatibility but does nothing without pet
        cancelDailyReminder()
    }

    /// Cancel the daily reminder
    func cancelDailyReminder() {
        cancelGuiltReminders()
    }

    /// Cancel today's notification if user has already worked out
    func cancelTodayReminderIfWorkedOut(hasWorkedOutToday: Bool) {
        guard hasWorkedOutToday else { return }
        cancelTodayGuiltNotifications()
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

}

// MARK: - Guilt Notification Messages

struct GuiltNotificationMessages {

    enum TimeOfDay {
        case morning
        case afternoon
    }

    static func getGuiltMessage(
        petName: String,
        species: PetSpecies,
        mood: PetMood,
        timeOfDay: TimeOfDay
    ) -> (title: String, body: String) {

        let messages = speciesMessages(for: species, petName: petName, mood: mood, timeOfDay: timeOfDay)
        return messages.randomElement() ?? (
            title: "\(petName) misses you!",
            body: "Log a workout to make your \(species.displayName) happy!"
        )
    }

    private static func speciesMessages(
        for species: PetSpecies,
        petName: String,
        mood: PetMood,
        timeOfDay: TimeOfDay
    ) -> [(title: String, body: String)] {

        switch species {
        case .plant:
            return plantGuiltMessages(petName: petName, mood: mood, timeOfDay: timeOfDay)
        case .cat:
            return catGuiltMessages(petName: petName, mood: mood, timeOfDay: timeOfDay)
        case .dog:
            return dogGuiltMessages(petName: petName, mood: mood, timeOfDay: timeOfDay)
        case .wolf:
            return wolfGuiltMessages(petName: petName, mood: mood, timeOfDay: timeOfDay)
        case .dragon:
            return dragonGuiltMessages(petName: petName, mood: mood, timeOfDay: timeOfDay)
        }
    }

    // MARK: - Plant Messages

    private static func plantGuiltMessages(petName: String, mood: PetMood, timeOfDay: TimeOfDay) -> [(title: String, body: String)] {
        var messages: [(String, String)] = [
            ("\(petName) is wilting...", "Your Sprout needs the energy from your workout to grow!"),
            ("\(petName) feels neglected", "Plants need attention too. A workout will help \(petName) flourish!"),
            ("Your Sprout is drooping", "\(petName) is waiting patiently for you to exercise..."),
            ("\(petName) is thirsty for XP!", "Water your Sprout with a workout today"),
            ("Don't forget \(petName)!", "Your little plant companion is counting on you to work out")
        ]

        if mood == .sad || mood == .unhappy || mood == .miserable {
            messages += [
                ("\(petName) is withering away!", "Your Sprout's leaves are turning brown. A workout could save them!"),
                ("URGENT: \(petName) needs you!", "Your plant's happiness is critically low. Please work out!"),
                ("\(petName) might not make it...", "Your Sprout is barely hanging on. One workout could change everything!")
            ]
        }

        if timeOfDay == .morning {
            messages += [
                ("Good morning from \(petName)!", "Your Sprout has been waiting all night for you to exercise"),
                ("\(petName) is ready to grow!", "Start the day right - your plant is counting on you")
            ]
        } else {
            messages += [
                ("\(petName) has been waiting all day", "The afternoon sun is fading, and so is \(petName)'s hope..."),
                ("Still no workout?", "\(petName) watched the whole day pass without you exercising")
            ]
        }

        return messages
    }

    // MARK: - Cat Messages

    private static func catGuiltMessages(petName: String, mood: PetMood, timeOfDay: TimeOfDay) -> [(title: String, body: String)] {
        var messages: [(String, String)] = [
            ("\(petName) is judging you", "Your Cat has noticed you haven't worked out. The disappointment is palpable."),
            ("\(petName) knocked over your water bottle", "Maybe they're trying to tell you something about hydration and exercise..."),
            ("*disappointed meow*", "\(petName) expected better from their human today"),
            ("\(petName) turned their back on you", "Win back your Cat's approval with a workout!"),
            ("Your Cat is unimpressed", "\(petName) is giving you the silent treatment until you exercise")
        ]

        if mood == .sad || mood == .unhappy || mood == .miserable {
            messages += [
                ("\(petName) has given up on you", "Your Cat doesn't even bother judging anymore. They're just... sad."),
                ("\(petName) stopped grooming", "A neglected cat is a sad cat. Please work out!"),
                ("*sad hiss*", "\(petName) has lost faith in their human")
            ]
        }

        if timeOfDay == .morning {
            messages += [
                ("\(petName) woke you up for this?", "Your Cat expected you to be exercising by now"),
                ("Morning judgment from \(petName)", "Your Cat has been waiting since dawn for you to exercise")
            ]
        } else {
            messages += [
                ("\(petName) noticed you're still here", "Even half-asleep, your Cat knows you skipped your workout"),
                ("Afternoon shade from \(petName)", "Your Cat's afternoon nap was ruined by your lack of exercise")
            ]
        }

        return messages
    }

    // MARK: - Dog Messages

    private static func dogGuiltMessages(petName: String, mood: PetMood, timeOfDay: TimeOfDay) -> [(title: String, body: String)] {
        var messages: [(String, String)] = [
            ("\(petName) is waiting by the door...", "Your Dog has been hoping you'd go for a workout. Those sad puppy eyes!"),
            ("\(petName) brought you their toy", "Your pup wants to play... and for you to exercise!"),
            ("*sad puppy whimper*", "\(petName) doesn't understand why you haven't worked out yet"),
            ("\(petName) keeps looking at you", "Those loyal eyes are asking: 'When are we exercising, human?'"),
            ("Your best friend misses you", "\(petName) has been patiently waiting for your workout all day")
        ]

        if mood == .sad || mood == .unhappy || mood == .miserable {
            messages += [
                ("\(petName) has stopped wagging", "Your Dog's tail hasn't moved in hours. They're losing hope."),
                ("\(petName) is lying by the door, waiting...", "Your loyal friend refuses to give up on you"),
                ("*heartbreaking whimper*", "\(petName) just wants their human to be healthy and happy")
            ]
        }

        if timeOfDay == .morning {
            messages += [
                ("\(petName) is READY FOR THE DAY!", "Your excited pup has been up since dawn waiting for workout time!"),
                ("Good morning! \(petName) is excited!", "Your Dog woke up hoping today would be a workout day...")
            ]
        } else {
            messages += [
                ("\(petName) has been waiting all day...", "Your loyal Dog still believes you'll work out. Don't let them down!"),
                ("The day is passing without exercise", "\(petName) watches the sun, still hoping you'll work out")
            ]
        }

        return messages
    }

    // MARK: - Wolf Messages

    private static func wolfGuiltMessages(petName: String, mood: PetMood, timeOfDay: TimeOfDay) -> [(title: String, body: String)] {
        var messages: [(String, String)] = [
            ("The pack is incomplete", "\(petName) needs their alpha to lead the hunt. Work out today!"),
            ("\(petName) howls for you", "Your Wolf senses you haven't trained. The pack grows weak."),
            ("A wolf alone is vulnerable", "\(petName) needs your strength. Don't abandon your pack!"),
            ("\(petName) is losing respect", "In the wild, the pack leader must stay strong. Work out!"),
            ("The hunt awaits", "\(petName) is ready to conquer, but needs you to lead the way")
        ]

        if mood == .sad || mood == .unhappy || mood == .miserable {
            messages += [
                ("\(petName) questions your leadership", "A pack leader who doesn't train loses their pack..."),
                ("*lonely howl*", "\(petName) feels abandoned by their alpha"),
                ("The pack bond is weakening", "Your Wolf needs you to step up. NOW.")
            ]
        }

        if timeOfDay == .morning {
            messages += [
                ("The morning hunt begins!", "\(petName) is ready to train at dawn. Where are you?"),
                ("\(petName) rises with the sun", "Your Wolf expected their pack leader to be training already")
            ]
        } else {
            messages += [
                ("The day slips away", "\(petName) watched prey escape all day while waiting for you"),
                ("Afternoon grows late", "\(petName) begins to wonder if the pack will hunt today at all")
            ]
        }

        return messages
    }

    // MARK: - Dragon Messages

    private static func dragonGuiltMessages(petName: String, mood: PetMood, timeOfDay: TimeOfDay) -> [(title: String, body: String)] {
        var messages: [(String, String)] = [
            ("\(petName)'s flame grows dim", "Even legendary creatures need their trainer to work out!"),
            ("A dragon's fire needs fuel", "\(petName) can only burn bright when you exercise!"),
            ("\(petName) is disappointed in you", "Dragons remember. They remember EVERYTHING."),
            ("Your Dragon awaits", "\(petName) expected legendary effort from you today..."),
            ("Legends are built daily", "\(petName) wonders if their trainer has what it takes")
        ]

        if mood == .sad || mood == .unhappy || mood == .miserable {
            messages += [
                ("\(petName)'s fire is dying", "A dragon without flame is just a large sad lizard..."),
                ("*feeble smoke puff*", "\(petName) can barely breathe fire anymore. Help them!"),
                ("The legend fades", "Your Dragon's power wanes with each missed workout")
            ]
        }

        if timeOfDay == .morning {
            messages += [
                ("\(petName) ROARS for morning training!", "Your Dragon expected to forge legends at dawn!"),
                ("The dragon stirs", "\(petName) awakens hungry for the fire of your workout")
            ]
        } else {
            messages += [
                ("\(petName) has been smoldering all day", "Your Dragon's patience runs thin. Work out before the fire dies!"),
                ("Evening approaches without glory", "\(petName) watched the sun arc across the sky without witnessing your strength")
            ]
        }

        return messages
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
