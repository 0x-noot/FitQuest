import SwiftUI
import SwiftData
import AuthenticationServices

struct OnboardingAuthStep: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var player: Player
    let onComplete: () -> Void

    @StateObject private var authManager = AuthManager.shared
    @State private var isSigningIn = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: PixelScale.px(4)) {
            Spacer()

            // Icon
            PixelIconView(icon: .person, size: 64)
                .padding(PixelScale.px(4))
                .background(PixelTheme.cardBackground)
                .pixelBorder(thickness: 2)

            // Title
            VStack(spacing: PixelScale.px(2)) {
                PixelText("CREATE ACCOUNT", size: .xlarge)

                PixelText("SYNC YOUR PROGRESS", size: .small, color: PixelTheme.textSecondary)
            }

            // Benefits list
            VStack(alignment: .leading, spacing: PixelScale.px(2)) {
                benefitRow(icon: .star, text: "BACKUP YOUR DATA")
                benefitRow(icon: .bolt, text: "SYNC ACROSS DEVICES")
                benefitRow(icon: .trophy, text: "JOIN FITNESS CLUBS")
            }
            .padding(PixelScale.px(3))
            .background(PixelTheme.cardBackground)
            .pixelOutline()
            .padding(.horizontal, PixelScale.px(4))

            Spacer()

            // Sign in with Apple button
            VStack(spacing: PixelScale.px(3)) {
                SignInWithAppleButton(.signIn, onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                }, onCompletion: { result in
                    handleSignInResult(result)
                })
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .cornerRadius(8)
                .padding(.horizontal, PixelScale.px(4))
                .disabled(isSigningIn)

                if isSigningIn {
                    HStack(spacing: PixelScale.px(2)) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: PixelTheme.text))
                            .scaleEffect(0.8)
                        PixelText("SIGNING IN...", size: .small, color: PixelTheme.textSecondary)
                    }
                }

                // Privacy note
                PixelText("YOUR DATA IS PRIVATE & SECURE", size: .small, color: PixelTheme.textSecondary)
                    .padding(.top, PixelScale.px(2))
            }
            .padding(.bottom, PixelScale.px(4))
        }
        .padding(.vertical, PixelScale.px(4))
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    @ViewBuilder
    private func benefitRow(icon: PixelIcon, text: String) -> some View {
        HStack(spacing: PixelScale.px(2)) {
            PixelIconView(icon: icon, size: 16, color: PixelTheme.gbLightest)
            PixelText(text, size: .small)
        }
    }

    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                handleSuccessfulSignIn(credential)
            }
        case .failure(let error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func handleSuccessfulSignIn(_ credential: ASAuthorizationAppleIDCredential) {
        isSigningIn = true

        let authState: AuthState
        if let existingAuth = player.authState {
            authState = existingAuth
        } else {
            authState = AuthState()
            modelContext.insert(authState)
            player.authState = authState
        }

        authManager.updateAuthState(authState, with: credential)

        player.appleUserID = credential.user

        if let fullName = credential.fullName {
            let formatter = PersonNameComponentsFormatter()
            formatter.style = .default
            let formattedName = formatter.string(from: fullName)
            if !formattedName.isEmpty {
                player.displayName = formattedName
            }
        }

        try? modelContext.save()

        Task {
            do {
                try await CloudKitService.shared.createOrUpdateUserProfile(
                    player: player,
                    appleUserID: credential.user
                )
            } catch {
                print("Failed to create CloudKit profile: \(error)")
            }

            await MainActor.run {
                isSigningIn = false
                onComplete()
            }
        }
    }
}

#Preview {
    OnboardingAuthStep(player: Player(name: "")) { }
        .modelContainer(for: [Player.self, AuthState.self], inMemory: true)
        .background(PixelTheme.background)
}
