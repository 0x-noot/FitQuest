import Foundation
import AuthenticationServices
import SwiftUI
import Combine

@MainActor
class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var isCheckingAuth = false
    @Published var authError: AuthError?
    @Published var currentUserID: String?
    @Published var displayName: String?

    private var authContinuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

    private override init() {
        super.init()
    }

    func signInWithApple() async throws -> ASAuthorizationAppleIDCredential {
        authError = nil

        return try await withCheckedThrowingContinuation { continuation in
            self.authContinuation = continuation

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
    }

    func checkCredentialState() async -> Bool {
        guard let userID = currentUserID else {
            isAuthenticated = false
            return false
        }

        isCheckingAuth = true
        defer { isCheckingAuth = false }

        do {
            let state = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ASAuthorizationAppleIDProvider.CredentialState, Error>) in
                ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: state)
                    }
                }
            }

            switch state {
            case .authorized:
                isAuthenticated = true
                return true
            case .revoked, .notFound:
                isAuthenticated = false
                currentUserID = nil
                authError = state == .revoked ? .credentialRevoked : .credentialNotFound
                return false
            case .transferred:
                isAuthenticated = false
                return false
            @unknown default:
                isAuthenticated = false
                return false
            }
        } catch {
            authError = .unknownError(error)
            isAuthenticated = false
            return false
        }
    }

    func signOut() {
        isAuthenticated = false
        currentUserID = nil
        displayName = nil
        authError = nil
    }

    func restoreSession(from authState: AuthState) {
        if authState.isAuthenticated, let userID = authState.appleUserID {
            currentUserID = userID
            displayName = authState.displayName
            isAuthenticated = true

            Task {
                await checkCredentialState()
            }
        }
    }

    func updateAuthState(_ authState: AuthState, with credential: ASAuthorizationAppleIDCredential) {
        authState.updateFromCredential(
            userID: credential.user,
            fullName: credential.fullName,
            email: credential.email
        )

        currentUserID = credential.user
        isAuthenticated = true

        if let fullName = credential.fullName {
            let formatter = PersonNameComponentsFormatter()
            formatter.style = .default
            let formattedName = formatter.string(from: fullName)
            if !formattedName.isEmpty {
                displayName = formattedName
            }
        }

        if displayName == nil {
            displayName = authState.displayName
        }
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                authContinuation?.resume(returning: credential)
                authContinuation = nil
            }
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            let authError: AuthError
            if let asError = error as? ASAuthorizationError {
                switch asError.code {
                case .canceled:
                    authError = .signInCancelled
                case .failed:
                    authError = .signInFailed
                case .invalidResponse:
                    authError = .signInFailed
                case .notHandled:
                    authError = .signInFailed
                case .notInteractive:
                    authError = .signInFailed
                case .unknown:
                    authError = .unknownError(error)
                @unknown default:
                    authError = .unknownError(error)
                }
            } else {
                authError = .unknownError(error)
            }

            self.authError = authError
            authContinuation?.resume(throwing: authError)
            authContinuation = nil
        }
    }
}
