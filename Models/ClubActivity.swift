import SwiftData
import Foundation

@Model
final class ClubActivity {
    var id: UUID = UUID()
    var cloudKitRecordName: String?
    var activityTypeRaw: String = ""
    var userID: String = ""
    var displayName: String = ""
    var xpEarned: Int = 0
    var workoutName: String?
    var message: String = ""
    var timestamp: Date = Date()
    var isOwnActivity: Bool = false

    var club: Club?

    var activityType: ActivityType {
        get { ActivityType(rawValue: activityTypeRaw) ?? .workout }
        set { activityTypeRaw = newValue.rawValue }
    }

    init(
        type: ActivityType,
        userID: String,
        displayName: String,
        xpEarned: Int = 0,
        workoutName: String? = nil,
        message: String,
        isOwnActivity: Bool = false
    ) {
        self.id = UUID()
        self.activityTypeRaw = type.rawValue
        self.userID = userID
        self.displayName = displayName
        self.xpEarned = xpEarned
        self.workoutName = workoutName
        self.message = message
        self.timestamp = Date()
        self.isOwnActivity = isOwnActivity
    }

    static func fromCloudKit(
        recordName: String,
        type: ActivityType,
        userID: String,
        displayName: String,
        xpEarned: Int,
        message: String,
        timestamp: Date,
        currentUserID: String
    ) -> ClubActivity {
        let activity = ClubActivity(
            type: type,
            userID: userID,
            displayName: displayName,
            xpEarned: xpEarned,
            message: message,
            isOwnActivity: userID == currentUserID
        )
        activity.cloudKitRecordName = recordName
        activity.timestamp = timestamp
        return activity
    }
}

struct LeaderboardEntry: Identifiable {
    let id: String
    let userID: String
    let displayName: String
    let weeklyXP: Int
    let weeklyWorkouts: Int
    let currentStreak: Int
    var rank: Int
    var isCurrentUser: Bool

    init(
        id: String = UUID().uuidString,
        userID: String,
        displayName: String,
        weeklyXP: Int,
        weeklyWorkouts: Int,
        currentStreak: Int,
        rank: Int = 0,
        isCurrentUser: Bool = false
    ) {
        self.id = id
        self.userID = userID
        self.displayName = displayName
        self.weeklyXP = weeklyXP
        self.weeklyWorkouts = weeklyWorkouts
        self.currentStreak = currentStreak
        self.rank = rank
        self.isCurrentUser = isCurrentUser
    }
}
