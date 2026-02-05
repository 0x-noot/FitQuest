import SwiftData
import Foundation

@Model
final class Club {
    var id: UUID = UUID()
    var cloudKitRecordName: String = ""
    var name: String = ""
    var clubDescription: String = ""
    var inviteCode: String = ""
    var isOwner: Bool = false
    var memberCount: Int = 1
    var maxMembers: Int = 50
    var isPublic: Bool = false
    var joinedAt: Date = Date()
    var lastActivitySync: Date?

    @Relationship(deleteRule: .cascade, inverse: \ClubActivity.club)
    var activities: [ClubActivity]? = []

    var player: Player?

    init(
        cloudKitRecordName: String,
        name: String,
        description: String,
        inviteCode: String,
        isOwner: Bool,
        memberCount: Int = 1,
        maxMembers: Int = 50,
        isPublic: Bool = false
    ) {
        self.id = UUID()
        self.cloudKitRecordName = cloudKitRecordName
        self.name = name
        self.clubDescription = description
        self.inviteCode = inviteCode
        self.isOwner = isOwner
        self.memberCount = memberCount
        self.maxMembers = maxMembers
        self.isPublic = isPublic
        self.joinedAt = Date()
    }

    var isFull: Bool {
        memberCount >= maxMembers
    }

    var memberCountText: String {
        "\(memberCount)/\(maxMembers) MEMBERS"
    }

    var sortedActivities: [ClubActivity] {
        (activities ?? []).sorted { $0.timestamp > $1.timestamp }
    }

    var recentActivities: [ClubActivity] {
        Array(sortedActivities.prefix(20))
    }
}

struct ClubSearchResult: Identifiable {
    let id: String
    let recordName: String
    let name: String
    let description: String
    let memberCount: Int
    let maxMembers: Int
    let isPublic: Bool

    var isFull: Bool {
        memberCount >= maxMembers
    }

    var memberCountText: String {
        "\(memberCount)/\(maxMembers)"
    }
}

struct ClubMember: Identifiable {
    let id: String
    let userID: String
    let displayName: String
    let isOwner: Bool
    let weeklyXP: Int
    let currentStreak: Int
}
