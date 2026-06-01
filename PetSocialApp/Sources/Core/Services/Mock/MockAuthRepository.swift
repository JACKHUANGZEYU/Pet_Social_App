import Foundation

public actor MockAuthRepository: AuthRepository {
    private var users: [AppUser]
    private var currentUserID: String?

    public init(
        users: [AppUser] = MockSeedData.users,
        currentUserID: String? = MockSeedData.defaultUserID
    ) {
        self.users = users
        self.currentUserID = currentUserID
    }

    public var currentUser: AppUser? {
        guard let currentUserID else { return nil }
        return users.first(where: { $0.id == currentUserID })
    }

    public func restoreSession() async -> AppUser? {
        currentUser
    }

    public func signIn(email: String, password: String) async throws -> AppUser {
        guard !password.isEmpty,
              let matchedUser = users.first(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame })
        else {
            throw AuthRepositoryError.invalidCredentials
        }

        currentUserID = matchedUser.id
        return matchedUser
    }

    public func signUp(email: String, password: String) async throws -> AppUser {
        guard !password.isEmpty else {
            throw AuthRepositoryError.invalidCredentials
        }

        if users.contains(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) {
            throw AuthRepositoryError.emailAlreadyExists
        }

        let handleSeed = email.split(separator: "@").first.map(String.init) ?? "petlover"
        let newUser = AppUser(
            email: email,
            displayName: handleSeed.capitalized
        )

        users.append(newUser)
        currentUserID = newUser.id
        return newUser
    }

    public func signOut() async {
        currentUserID = nil
    }
}
