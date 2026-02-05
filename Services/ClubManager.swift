import Foundation

struct ClubManager {
    static let maxClubsPerUser = 5
    static let maxMembersPerClub = 50
    static let inviteCodeLength = 6
    static let minClubNameLength = 3
    static let maxClubNameLength = 30
    static let maxDescriptionLength = 200

    static func generateInviteCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<inviteCodeLength).map { _ in characters.randomElement()! })
    }

    static func validateClubName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= minClubNameLength && trimmed.count <= maxClubNameLength
    }

    static func validateDescription(_ description: String) -> Bool {
        return description.count <= maxDescriptionLength
    }

    static func canCreateClub(currentClubCount: Int) -> Bool {
        return currentClubCount < maxClubsPerUser
    }

    static func canJoinClub(currentClubCount: Int) -> Bool {
        return currentClubCount < maxClubsPerUser
    }

    static func formatInviteCode(_ code: String) -> String {
        let cleaned = code.uppercased().filter { $0.isLetter || $0.isNumber }
        return String(cleaned.prefix(inviteCodeLength))
    }

    static func formatActivityMessage(type: ActivityType, displayName: String, xp: Int?) -> String {
        switch type {
        case .workout:
            if let xp = xp, xp > 0 {
                return "\(displayName) completed a workout and earned \(xp) XP"
            } else {
                return "\(displayName) completed a workout"
            }
        case .joined:
            return "\(displayName) joined the club"
        case .levelUp:
            return "\(displayName)'s pet leveled up!"
        case .evolution:
            return "\(displayName)'s pet evolved!"
        case .streak:
            return "\(displayName) is on fire with their streak!"
        }
    }

    static func formatMemberCount(_ count: Int, max: Int) -> String {
        return "\(count)/\(max) MEMBERS"
    }

    static func formatRank(_ rank: Int) -> String {
        switch rank {
        case 1: return "1ST"
        case 2: return "2ND"
        case 3: return "3RD"
        default: return "\(rank)TH"
        }
    }

    static func timeAgoString(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "JUST NOW"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)M AGO"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)H AGO"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)D AGO"
        } else {
            let weeks = Int(interval / 604800)
            return "\(weeks)W AGO"
        }
    }
}
