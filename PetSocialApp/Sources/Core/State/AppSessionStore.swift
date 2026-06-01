import Combine
import Foundation

@MainActor
public final class AppSessionStore: ObservableObject {
    public enum AuthState: Equatable {
        case launching
        case signedOut
        case signedIn
    }

    @Published public private(set) var authState: AuthState
    @Published public private(set) var currentUser: AppUser?
    @Published public private(set) var currentPetProfile: PetProfile?

    private let authRepository: any AuthRepository
    private let petSocialRepository: any PetSocialRepository

    public init(
        authState: AuthState = .launching,
        authRepository: any AuthRepository = MockAuthRepository(),
        petSocialRepository: any PetSocialRepository = MockPetSocialRepository()
    ) {
        self.authState = authState
        self.authRepository = authRepository
        self.petSocialRepository = petSocialRepository
    }

    public func restore() async {
        let restoredUser = await authRepository.restoreSession()
        await applyAuthenticatedUser(restoredUser)
    }

    public func signIn(email: String, password: String) async throws {
        let signedInUser = try await authRepository.signIn(email: email, password: password)
        await applyAuthenticatedUser(signedInUser)
    }

    public func signUp(email: String, password: String) async throws {
        let signedUpUser = try await authRepository.signUp(email: email, password: password)
        await applyAuthenticatedUser(signedUpUser)
    }

    public func signOut() async {
        await authRepository.signOut()
        currentUser = nil
        currentPetProfile = nil
        authState = .signedOut
    }

    public var isLoading: Bool {
        authState == .launching
    }

    public var isAuthenticated: Bool {
        currentUser != nil
    }

    public var hasCompletedOnboarding: Bool {
        currentPetProfile != nil
    }

    public func completeOnboarding(with profile: PetProfile) {
        currentPetProfile = profile
    }

    public func refreshCurrentPetProfile() async {
        guard let userID = currentUser?.id else { return }
        currentPetProfile = try? await petSocialRepository.fetchPetProfile(ownerUserID: userID)
    }

    private func applyAuthenticatedUser(_ user: AppUser?) async {
        currentUser = user

        guard let user else {
            currentPetProfile = nil
            authState = .signedOut
            return
        }

        currentPetProfile = try? await petSocialRepository.fetchPetProfile(ownerUserID: user.id)
        authState = .signedIn
    }
}

public typealias AppSession = AppSessionStore
