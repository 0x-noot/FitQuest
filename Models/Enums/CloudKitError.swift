import Foundation

enum CloudKitError: Error, LocalizedError {
    case notAuthenticated
    case networkUnavailable
    case recordNotFound
    case recordAlreadyExists
    case permissionDenied
    case quotaExceeded
    case serverError
    case invalidData
    case clubFull
    case clubNotFound
    case invalidInviteCode
    case alreadyMember
    case notMember
    case notOwner
    case maxClubsReached
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to use this feature."
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .recordNotFound:
            return "The requested data was not found."
        case .recordAlreadyExists:
            return "This record already exists."
        case .permissionDenied:
            return "You don't have permission to perform this action."
        case .quotaExceeded:
            return "Storage quota exceeded. Please try again later."
        case .serverError:
            return "Server error. Please try again later."
        case .invalidData:
            return "Invalid data received from server."
        case .clubFull:
            return "This club is full and cannot accept new members."
        case .clubNotFound:
            return "Club not found."
        case .invalidInviteCode:
            return "Invalid invite code. Please check and try again."
        case .alreadyMember:
            return "You are already a member of this club."
        case .notMember:
            return "You are not a member of this club."
        case .notOwner:
            return "Only the club owner can perform this action."
        case .maxClubsReached:
            return "You have reached the maximum number of clubs you can join."
        case .unknownError(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}
