import Combine
import Foundation

@MainActor
final class EditPetProfileViewModel: ObservableObject {
    @Published var draft: PetProfileDraft
    @Published private(set) var isSaving = false
    @Published private(set) var isGeneratingAI = false
    @Published private(set) var statusMessage: String?

    private let originalProfile: PetProfile
    private let session: AppSessionStore
    private let repository: any PetSocialRepository
    private let mediaStorage: any PetMediaStorage
    private let aiService: any PetAIService
    private let onSaved: (PetProfile) -> Void

    init(
        profile: PetProfile,
        session: AppSessionStore,
        repository: any PetSocialRepository,
        mediaStorage: any PetMediaStorage,
        aiService: any PetAIService = MockPetAIService(),
        onSaved: @escaping (PetProfile) -> Void = { _ in }
    ) {
        self.originalProfile = profile
        self.draft = PetProfileDraft(profile: profile)
        self.session = session
        self.repository = repository
        self.mediaStorage = mediaStorage
        self.aiService = aiService
        self.onSaved = onSaved
    }

    func applyAvatarAsset(_ asset: PickedImageAsset?) {
        draft.avatarAsset = asset
        if asset != nil {
            draft.avatarURL = ""
        }
    }

    func remoteAvatarURLDidChange() {
        if !draft.avatarURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.avatarAsset = nil
        }
    }

    func addPendingTag() {
        let sanitized = sanitizeTag(draft.pendingTag)
        guard !sanitized.isEmpty else { return }
        guard !draft.personalityTags.contains(sanitized) else {
            draft.pendingTag = ""
            return
        }

        draft.personalityTags.append(sanitized)
        draft.pendingTag = ""
    }

    func removeTag(_ tag: String) {
        draft.personalityTags.removeAll { $0 == tag }
    }

    func polishWithAI(style: PetAIWritingStyle = .playful) {
        isGeneratingAI = true
        statusMessage = nil

        let currentDraft = draft
        Task {
            do {
                let suggestion = try await aiService.polishProfile(
                    profile: originalProfile,
                    draft: currentDraft,
                    style: style
                )
                draft.bio = suggestion.bio
                draft.personalityTags = mergedTags(draft.personalityTags, suggestion.tags)
                isGeneratingAI = false
                statusMessage = "AI polished this pet voice."
            } catch {
                isGeneratingAI = false
                statusMessage = error.localizedDescription
            }
        }
    }

    func save() {
        statusMessage = nil

        let trimmedAge = draft.age.trimmingCharacters(in: .whitespacesAndNewlines)

        if let validationMessage = PetSocialValidation.validateAge(trimmedAge) {
            statusMessage = validationMessage
            return
        }

        let age = Int(trimmedAge) ?? originalProfile.age
        let trimmedName = draft.petName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHandle = draft.petHandle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = draft.bio.trimmingCharacters(in: .whitespacesAndNewlines)

        if let validationMessage = PetSocialValidation.validatePetName(trimmedName) {
            statusMessage = validationMessage
            return
        }

        if let validationMessage = PetSocialValidation.validateHandle(trimmedHandle) {
            statusMessage = validationMessage
            return
        }

        if let validationMessage = PetSocialValidation.validateBio(trimmedBio) {
            statusMessage = validationMessage
            return
        }

        if !draft.pendingTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            addPendingTag()
        }

        isSaving = true
        let finalDraft = draft

        Task {
            do {
                let avatarURL: URL?
                if let avatarAsset = finalDraft.avatarAsset {
                    avatarURL = try await mediaStorage.uploadPickedImage(
                        avatarAsset,
                        kind: .avatar(profileID: originalProfile.id)
                    )
                } else {
                    avatarURL = try await mediaStorage.resolveRemoteImageURL(
                        from: finalDraft.avatarURL,
                        kind: .avatar(profileID: originalProfile.id)
                    )
                }

                let updatedProfile = PetProfile(
                    id: originalProfile.id,
                    ownerUserID: originalProfile.ownerUserID,
                    name: trimmedName,
                    username: PetSocialValidation.normalizedHandle(trimmedHandle),
                    avatarURL: avatarURL,
                    petType: finalDraft.petType,
                    breed: finalDraft.breed.trimmingCharacters(in: .whitespacesAndNewlines),
                    age: age,
                    gender: finalDraft.gender,
                    bio: trimmedBio,
                    personalityTags: finalDraft.personalityTags,
                    createdAt: originalProfile.createdAt
                )

                try await repository.upsertPetProfile(updatedProfile)
                await session.refreshCurrentPetProfile()
                isSaving = false
                statusMessage = "Profile updated."
                onSaved(updatedProfile)
            } catch {
                isSaving = false
                statusMessage = error.localizedDescription
            }
        }
    }

    private func sanitizeTag(_ tag: String) -> String {
        tag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()
    }

    private func mergedTags(_ existingTags: [String], _ suggestedTags: [String]) -> [String] {
        var seen = Set<String>()
        return (existingTags + suggestedTags)
            .map(sanitizeTag(_:))
            .filter { tag in
                guard !tag.isEmpty, !seen.contains(tag) else { return false }
                seen.insert(tag)
                return true
            }
            .prefix(8)
            .map(String.init)
    }
}
