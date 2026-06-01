import Foundation

enum PetOnboardingServiceError: LocalizedError {
    case missingOwner
    case invalidAge

    var errorDescription: String? {
        switch self {
        case .missingOwner:
            return "Sign in before creating a pet profile."
        case .invalidAge:
            return "Age should be a whole number between 0 and 40."
        }
    }
}

protocol PetOnboardingServicing {
    func createPetProfile(draft: PetProfileDraft, ownerUserID: String?) async throws -> PetProfile
    func resolveAvatarURL(for profile: PetProfile, draft: PetProfileDraft) async throws -> URL?
}

struct PetOnboardingService: PetOnboardingServicing {
    private let mediaStorage: any PetMediaStorage

    init(mediaStorage: any PetMediaStorage = MockPetMediaStorage()) {
        self.mediaStorage = mediaStorage
    }

    func createPetProfile(draft: PetProfileDraft, ownerUserID: String?) async throws -> PetProfile {
        try await Task.sleep(nanoseconds: 550_000_000)

        guard let ownerUserID, !ownerUserID.isEmpty else {
            throw PetOnboardingServiceError.missingOwner
        }

        guard let age = Int(draft.age.trimmingCharacters(in: .whitespacesAndNewlines)),
              (0...40).contains(age) else {
            throw PetOnboardingServiceError.invalidAge
        }

        return PetProfile(
            ownerUserID: ownerUserID,
            name: draft.petName.trimmingCharacters(in: .whitespacesAndNewlines),
            username: PetSocialValidation.normalizedHandle(draft.petHandle),
            avatarURL: nil,
            petType: draft.petType,
            breed: draft.breed.trimmingCharacters(in: .whitespacesAndNewlines),
            age: age,
            gender: draft.gender,
            bio: draft.bio.trimmingCharacters(in: .whitespacesAndNewlines),
            personalityTags: draft.personalityTags
        )
    }

    func resolveAvatarURL(for profile: PetProfile, draft: PetProfileDraft) async throws -> URL? {
        if let avatarAsset = draft.avatarAsset {
            return try await mediaStorage.uploadPickedImage(
                avatarAsset,
                kind: .avatar(profileID: profile.id)
            )
        }

        return try await mediaStorage.resolveRemoteImageURL(
            from: draft.avatarURL,
            kind: .avatar(profileID: profile.id)
        )
    }
}

typealias MockPetOnboardingService = PetOnboardingService
