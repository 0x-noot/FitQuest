import Foundation

enum SyncStatus: Equatable {
    case idle
    case syncing
    case success
    case error(String)
    case offline

    var displayText: String {
        switch self {
        case .idle:
            return "Ready"
        case .syncing:
            return "Syncing..."
        case .success:
            return "Synced"
        case .error(let message):
            return "Error: \(message)"
        case .offline:
            return "Offline"
        }
    }

    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}
