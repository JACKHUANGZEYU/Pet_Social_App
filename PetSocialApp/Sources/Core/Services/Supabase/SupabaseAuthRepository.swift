import Foundation

#if canImport(Supabase)
import Supabase

actor SupabaseAuthRepository: AuthRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    var currentUser: AppUser? {
        client.auth.currentUser.map(AppUser.init(supabaseUser:))
    }

    func restoreSession() async -> AppUser? {
        if let currentUser {
            return currentUser
        }

        do {
            let session = try await client.auth.session
            return AppUser(supabaseUser: session.user)
        } catch {
            return nil
        }
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        try await client.auth.signIn(
            email: email,
            password: password
        )

        if let currentUser {
            return currentUser
        }

        let user = try await client.auth.user()
        return AppUser(supabaseUser: user)
    }

    func signUp(email: String, password: String) async throws -> AppUser {
        try await client.auth.signUp(
            email: email,
            password: password
        )

        if let currentUser {
            return currentUser
        }

        do {
            let user = try await client.auth.user()
            return AppUser(supabaseUser: user)
        } catch {
            throw AuthRepositoryError.emailConfirmationRequired
        }
    }

    func signOut() async {
        try? await client.auth.signOut()
    }
}

private extension AppUser {
    init(supabaseUser: User) {
        self.init(
            id: supabaseUser.id.uuidString.lowercased(),
            email: supabaseUser.email ?? "",
            displayName: SupabaseUserMetadata.displayName(from: supabaseUser),
            createdAt: supabaseUser.createdAt
        )
    }
}

private enum SupabaseUserMetadata {
    static func displayName(from user: User) -> String {
        let metadata = user.userMetadata

        if case let .string(name)? = metadata["display_name"] {
            return name
        }

        if case let .string(name)? = metadata["name"] {
            return name
        }

        return user.email?.split(separator: "@").first.map(String.init)?.capitalized ?? "Pet Parent"
    }
}
#endif
