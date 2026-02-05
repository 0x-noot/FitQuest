import SwiftData
import Foundation

@Model
final class AuthState {
    var id: UUID = UUID()
    var appleUserID: String?
    var displayName: String?
    var email: String?
    var cloudKitRecordName: String?
    var isAuthenticated: Bool = false
    var lastAuthCheck: Date?
    var createdAt: Date = Date()

    // Inverse relationship for CloudKit
    var player: Player?

    init() {
        self.id = UUID()
        self.isAuthenticated = false
        self.createdAt = Date()
    }

    func updateFromCredential(userID: String, fullName: PersonNameComponents?, email: String?) {
        self.appleUserID = userID
        self.isAuthenticated = true
        self.lastAuthCheck = Date()

        if let fullName = fullName {
            let formatter = PersonNameComponentsFormatter()
            formatter.style = .default
            let formattedName = formatter.string(from: fullName)
            if !formattedName.isEmpty {
                self.displayName = formattedName
            }
        }

        if let email = email {
            self.email = email
        }
    }

    func signOut() {
        self.isAuthenticated = false
        self.lastAuthCheck = nil
    }
}
