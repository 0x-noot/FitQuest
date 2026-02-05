import Foundation
import CloudKit
import SwiftUI
import Combine

@MainActor
class CloudKitService: ObservableObject {
    static let shared = CloudKitService()

    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncError: CloudKitError?

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let publicDatabase: CKDatabase

    private let userProfileRecordType = "UserProfile"
    private let clubRecordType = "Club"
    private let clubActivityRecordType = "ClubActivity"
    private let leaderboardEntryRecordType = "LeaderboardEntry"

    private init() {
        container = CKContainer(identifier: "iCloud.com.PAMP-Solutions.FitQuestApp")
        privateDatabase = container.privateCloudDatabase
        publicDatabase = container.publicCloudDatabase
    }

    // MARK: - User Profile Operations

    func createOrUpdateUserProfile(player: Player, appleUserID: String) async throws {
        syncStatus = .syncing

        do {
            let existingRecord = try await fetchUserProfileRecord(appleUserID: appleUserID)

            if let record = existingRecord {
                record["displayName"] = player.displayName ?? "Player"
                record["totalXP"] = player.pet?.totalXP ?? 0
                record["currentStreak"] = player.currentStreak
                record["highestStreak"] = player.highestStreak
                record["totalWorkouts"] = (player.workouts ?? []).count
                record["updatedAt"] = Date()

                _ = try await privateDatabase.save(record)
                player.cloudKitRecordName = record.recordID.recordName
            } else {
                let recordID = CKRecord.ID(recordName: UUID().uuidString)
                let record = CKRecord(recordType: userProfileRecordType, recordID: recordID)

                record["appleUserID"] = appleUserID
                record["displayName"] = player.displayName ?? "Player"
                record["totalXP"] = player.pet?.totalXP ?? 0
                record["currentStreak"] = player.currentStreak
                record["highestStreak"] = player.highestStreak
                record["totalWorkouts"] = (player.workouts ?? []).count
                record["createdAt"] = Date()
                record["updatedAt"] = Date()

                let savedRecord = try await privateDatabase.save(record)
                player.cloudKitRecordName = savedRecord.recordID.recordName
            }

            syncStatus = .success
        } catch {
            syncStatus = .error(error.localizedDescription)
            throw mapCloudKitError(error)
        }
    }

    func fetchUserProfileRecord(appleUserID: String) async throws -> CKRecord? {
        let predicate = NSPredicate(format: "appleUserID == %@", appleUserID)
        let query = CKQuery(recordType: userProfileRecordType, predicate: predicate)

        do {
            let (results, _) = try await privateDatabase.records(matching: query)
            for (_, result) in results {
                if case .success(let record) = result {
                    return record
                }
            }
            return nil
        } catch {
            throw mapCloudKitError(error)
        }
    }

    // MARK: - Club Operations

    func createClub(name: String, description: String, isPublic: Bool, ownerID: String, ownerDisplayName: String) async throws -> CKRecord {
        syncStatus = .syncing

        do {
            let recordID = CKRecord.ID(recordName: UUID().uuidString)
            let record = CKRecord(recordType: clubRecordType, recordID: recordID)

            let inviteCode = ClubManager.generateInviteCode()

            record["name"] = name
            record["description"] = description
            record["inviteCode"] = inviteCode
            record["ownerUserID"] = ownerID
            record["memberUserIDs"] = [ownerID]
            record["memberCount"] = 1
            record["maxMembers"] = ClubManager.maxMembersPerClub
            record["isPublic"] = isPublic ? 1 : 0
            record["createdAt"] = Date()

            let savedRecord = try await publicDatabase.save(record)

            try await postActivity(
                clubRecordName: savedRecord.recordID.recordName,
                userID: ownerID,
                displayName: ownerDisplayName,
                type: .joined,
                xp: 0,
                message: "\(ownerDisplayName) created the club"
            )

            syncStatus = .success
            return savedRecord
        } catch {
            syncStatus = .error(error.localizedDescription)
            throw mapCloudKitError(error)
        }
    }

    func fetchClub(inviteCode: String) async throws -> CKRecord? {
        let predicate = NSPredicate(format: "inviteCode == %@", inviteCode.uppercased())
        let query = CKQuery(recordType: clubRecordType, predicate: predicate)

        do {
            let (results, _) = try await publicDatabase.records(matching: query)
            for (_, result) in results {
                if case .success(let record) = result {
                    return record
                }
            }
            return nil
        } catch {
            throw mapCloudKitError(error)
        }
    }

    func fetchClubByRecordName(_ recordName: String) async throws -> CKRecord? {
        let recordID = CKRecord.ID(recordName: recordName)
        do {
            return try await publicDatabase.record(for: recordID)
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        } catch {
            throw mapCloudKitError(error)
        }
    }

    func searchPublicClubs(query: String) async throws -> [ClubSearchResult] {
        let predicate: NSPredicate
        if query.isEmpty {
            predicate = NSPredicate(format: "isPublic == 1")
        } else {
            predicate = NSPredicate(format: "isPublic == 1 AND name BEGINSWITH %@", query)
        }

        let ckQuery = CKQuery(recordType: clubRecordType, predicate: predicate)
        ckQuery.sortDescriptors = [NSSortDescriptor(key: "memberCount", ascending: false)]

        do {
            let (results, _) = try await publicDatabase.records(matching: ckQuery, resultsLimit: 20)

            var clubs: [ClubSearchResult] = []
            for (_, result) in results {
                if case .success(let record) = result {
                    let club = ClubSearchResult(
                        id: record.recordID.recordName,
                        recordName: record.recordID.recordName,
                        name: record["name"] as? String ?? "",
                        description: record["description"] as? String ?? "",
                        memberCount: record["memberCount"] as? Int ?? 0,
                        maxMembers: record["maxMembers"] as? Int ?? 50,
                        isPublic: (record["isPublic"] as? Int ?? 0) == 1
                    )
                    clubs.append(club)
                }
            }
            return clubs
        } catch {
            throw mapCloudKitError(error)
        }
    }

    func joinClub(clubRecord: CKRecord, userID: String, displayName: String) async throws {
        syncStatus = .syncing

        do {
            var memberIDs = clubRecord["memberUserIDs"] as? [String] ?? []

            if memberIDs.contains(userID) {
                throw CloudKitError.alreadyMember
            }

            let memberCount = clubRecord["memberCount"] as? Int ?? 0
            let maxMembers = clubRecord["maxMembers"] as? Int ?? 50

            if memberCount >= maxMembers {
                throw CloudKitError.clubFull
            }

            memberIDs.append(userID)
            clubRecord["memberUserIDs"] = memberIDs
            clubRecord["memberCount"] = memberCount + 1

            _ = try await publicDatabase.save(clubRecord)

            try await postActivity(
                clubRecordName: clubRecord.recordID.recordName,
                userID: userID,
                displayName: displayName,
                type: .joined,
                xp: 0,
                message: "\(displayName) joined the club"
            )

            syncStatus = .success
        } catch let error as CloudKitError {
            syncStatus = .error(error.localizedDescription)
            throw error
        } catch {
            syncStatus = .error(error.localizedDescription)
            throw mapCloudKitError(error)
        }
    }

    func leaveClub(clubRecord: CKRecord, userID: String, displayName: String) async throws {
        syncStatus = .syncing

        do {
            let ownerID = clubRecord["ownerUserID"] as? String
            if ownerID == userID {
                throw CloudKitError.notOwner
            }

            var memberIDs = clubRecord["memberUserIDs"] as? [String] ?? []
            memberIDs.removeAll { $0 == userID }

            let memberCount = max(0, (clubRecord["memberCount"] as? Int ?? 1) - 1)

            clubRecord["memberUserIDs"] = memberIDs
            clubRecord["memberCount"] = memberCount

            _ = try await publicDatabase.save(clubRecord)
            syncStatus = .success
        } catch let error as CloudKitError {
            syncStatus = .error(error.localizedDescription)
            throw error
        } catch {
            syncStatus = .error(error.localizedDescription)
            throw mapCloudKitError(error)
        }
    }

    func deleteClub(clubRecord: CKRecord, userID: String) async throws {
        let ownerID = clubRecord["ownerUserID"] as? String
        if ownerID != userID {
            throw CloudKitError.notOwner
        }

        syncStatus = .syncing

        do {
            try await publicDatabase.deleteRecord(withID: clubRecord.recordID)
            syncStatus = .success
        } catch {
            syncStatus = .error(error.localizedDescription)
            throw mapCloudKitError(error)
        }
    }

    func fetchUserClubs(userID: String) async throws -> [CKRecord] {
        let predicate = NSPredicate(format: "memberUserIDs CONTAINS %@", userID)
        let query = CKQuery(recordType: clubRecordType, predicate: predicate)

        do {
            let (results, _) = try await publicDatabase.records(matching: query)

            var clubs: [CKRecord] = []
            for (_, result) in results {
                if case .success(let record) = result {
                    clubs.append(record)
                }
            }
            return clubs
        } catch {
            throw mapCloudKitError(error)
        }
    }

    // MARK: - Activity Operations

    func postActivity(clubRecordName: String, userID: String, displayName: String, type: ActivityType, xp: Int, message: String? = nil) async throws {
        let recordID = CKRecord.ID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: clubActivityRecordType, recordID: recordID)

        let activityMessage = message ?? ClubManager.formatActivityMessage(type: type, displayName: displayName, xp: xp)

        record["clubRecordName"] = clubRecordName
        record["userID"] = userID
        record["displayName"] = displayName
        record["activityType"] = type.rawValue
        record["xpEarned"] = xp
        record["message"] = activityMessage
        record["timestamp"] = Date()

        do {
            _ = try await publicDatabase.save(record)
        } catch {
            throw mapCloudKitError(error)
        }
    }

    func fetchRecentActivities(clubRecordName: String, limit: Int = 50, currentUserID: String) async throws -> [ClubActivity] {
        let predicate = NSPredicate(format: "clubRecordName == %@", clubRecordName)
        let query = CKQuery(recordType: clubActivityRecordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do {
            let (results, _) = try await publicDatabase.records(matching: query, resultsLimit: limit)

            var activities: [ClubActivity] = []
            for (_, result) in results {
                if case .success(let record) = result {
                    let typeRaw = record["activityType"] as? String ?? "workout"
                    let type = ActivityType(rawValue: typeRaw) ?? .workout
                    let userID = record["userID"] as? String ?? ""

                    let activity = ClubActivity.fromCloudKit(
                        recordName: record.recordID.recordName,
                        type: type,
                        userID: userID,
                        displayName: record["displayName"] as? String ?? "Unknown",
                        xpEarned: record["xpEarned"] as? Int ?? 0,
                        message: record["message"] as? String ?? "",
                        timestamp: record["timestamp"] as? Date ?? Date(),
                        currentUserID: currentUserID
                    )
                    activities.append(activity)
                }
            }
            return activities
        } catch {
            throw mapCloudKitError(error)
        }
    }

    // MARK: - Leaderboard Operations

    func updateLeaderboardEntry(clubRecordName: String, userID: String, displayName: String, weeklyXP: Int, weeklyWorkouts: Int, streak: Int) async throws {
        let weekStart = getWeekStartDate()

        let predicate = NSPredicate(format: "clubRecordName == %@ AND userID == %@ AND weekStartDate == %@", clubRecordName, userID, weekStart as NSDate)
        let query = CKQuery(recordType: leaderboardEntryRecordType, predicate: predicate)

        do {
            let (results, _) = try await publicDatabase.records(matching: query)

            var existingRecord: CKRecord?
            for (_, result) in results {
                if case .success(let record) = result {
                    existingRecord = record
                    break
                }
            }

            if let record = existingRecord {
                record["weeklyXP"] = weeklyXP
                record["weeklyWorkouts"] = weeklyWorkouts
                record["currentStreak"] = streak
                record["displayName"] = displayName
                _ = try await publicDatabase.save(record)
            } else {
                let recordID = CKRecord.ID(recordName: UUID().uuidString)
                let record = CKRecord(recordType: leaderboardEntryRecordType, recordID: recordID)

                record["clubRecordName"] = clubRecordName
                record["weekStartDate"] = weekStart
                record["userID"] = userID
                record["displayName"] = displayName
                record["weeklyXP"] = weeklyXP
                record["weeklyWorkouts"] = weeklyWorkouts
                record["currentStreak"] = streak

                _ = try await publicDatabase.save(record)
            }
        } catch {
            throw mapCloudKitError(error)
        }
    }

    func fetchLeaderboard(clubRecordName: String, currentUserID: String) async throws -> [LeaderboardEntry] {
        let weekStart = getWeekStartDate()

        let predicate = NSPredicate(format: "clubRecordName == %@ AND weekStartDate == %@", clubRecordName, weekStart as NSDate)
        let query = CKQuery(recordType: leaderboardEntryRecordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "weeklyXP", ascending: false)]

        do {
            let (results, _) = try await publicDatabase.records(matching: query, resultsLimit: 50)

            var entries: [LeaderboardEntry] = []
            var rank = 1

            for (_, result) in results {
                if case .success(let record) = result {
                    let userID = record["userID"] as? String ?? ""
                    let entry = LeaderboardEntry(
                        id: record.recordID.recordName,
                        userID: userID,
                        displayName: record["displayName"] as? String ?? "Unknown",
                        weeklyXP: record["weeklyXP"] as? Int ?? 0,
                        weeklyWorkouts: record["weeklyWorkouts"] as? Int ?? 0,
                        currentStreak: record["currentStreak"] as? Int ?? 0,
                        rank: rank,
                        isCurrentUser: userID == currentUserID
                    )
                    entries.append(entry)
                    rank += 1
                }
            }
            return entries
        } catch {
            throw mapCloudKitError(error)
        }
    }

    // MARK: - Helpers

    private func getWeekStartDate() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
    }

    private func mapCloudKitError(_ error: Error) -> CloudKitError {
        if let ckError = error as? CKError {
            switch ckError.code {
            case .notAuthenticated:
                return .notAuthenticated
            case .networkUnavailable, .networkFailure:
                return .networkUnavailable
            case .unknownItem:
                return .recordNotFound
            case .serverRecordChanged:
                return .serverError
            case .quotaExceeded:
                return .quotaExceeded
            case .permissionFailure:
                return .permissionDenied
            default:
                return .unknownError(error)
            }
        }
        return .unknownError(error)
    }
}
