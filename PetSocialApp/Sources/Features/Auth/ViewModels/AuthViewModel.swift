import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var form = AuthFormState()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?

    private let session: AppSessionStore

    init(session: AppSessionStore = AppSessionStore(authState: .signedOut)) {
        self.session = session
    }

    func updateMode(_ mode: AuthMode) {
        guard form.mode != mode else { return }
        form.mode = mode
        errorMessage = nil
        successMessage = nil
        if mode == .login {
            form.confirmPassword = ""
            form.ownerDisplayName = ""
        }
    }

    func submit() {
        errorMessage = nil
        successMessage = nil

        let email = form.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = form.password
        let confirmPassword = form.confirmPassword
        let ownerDisplayName = form.ownerDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty, email.contains("@") else {
            errorMessage = "Enter a valid email address."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password should be at least 6 characters."
            return
        }

        if form.mode == .signUp {
            guard !ownerDisplayName.isEmpty else {
                errorMessage = "Add the owner's display name for onboarding."
                return
            }

            guard confirmPassword == password else {
                errorMessage = "Passwords do not match."
                return
            }
        }

        isLoading = true

        Task {
            do {
                switch form.mode {
                case .login:
                    try await session.signIn(email: email, password: password)
                    successMessage = "Login succeeded. Welcome back to your pet's world."
                case .signUp:
                    try await session.signUp(email: email, password: password)
                    successMessage = ownerDisplayName.isEmpty
                        ? "Account created. Next stop: build your pet's profile."
                        : "Account created for \(ownerDisplayName). Next stop: build your pet's profile."
                }

                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
