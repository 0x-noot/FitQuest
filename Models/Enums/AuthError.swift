import Foundation

enum AuthError: Error, LocalizedError {
    case signInFailed
    case signInCancelled
    case credentialRevoked
    case credentialNotFound
    case networkError
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .signInFailed:
            return "Sign in failed. Please try again."
        case .signInCancelled:
            return "Sign in was cancelled."
        case .credentialRevoked:
            return "Your Apple ID credentials have been revoked. Please sign in again."
        case .credentialNotFound:
            return "No credentials found. Please sign in."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .unknownError(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}
