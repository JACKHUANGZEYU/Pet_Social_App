import Foundation

public enum AuthRepositoryError: LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case emailConfirmationRequired

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "The email or password is incorrect."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .emailConfirmationRequired:
            return "Check your email to confirm the account, or disable email confirmation for MVP testing."
        }
    }
}

public protocol AuthRepository: Sendable {
    var currentUser: AppUser? { get async }

    func restoreSession() async -> AppUser?
    func signIn(email: String, password: String) async throws -> AppUser
    func signUp(email: String, password: String) async throws -> AppUser
    func signOut() async
}
