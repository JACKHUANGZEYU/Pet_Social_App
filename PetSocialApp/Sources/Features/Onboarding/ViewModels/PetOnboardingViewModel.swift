import Combine
import Foundation

@MainActor
final class PetOnboardingViewModel: ObservableObject {
    @Published var draft = PetProfileDraft()
    @Published private(set) var currentStep: PetOnboardingStep = .identity
    @Published private(set) var isSaving = false
    @Published private(set) var isGeneratingAI = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?

    private let session: AppSessionStore
    private let repository: any PetSocialRepository
    private let service: PetOnboardingServicing
    private let aiService: any PetAIService
    private let onComplete: (PetProfile) -> Void

    init(
        session: AppSessionStore = AppSessionStore(authState: .signedIn),
        repository: any PetSocialRepository = MockPetSocialRepository(),
        service: PetOnboardingServicing = MockPetOnboardingService(),
        aiService: any PetAIService = MockPetAIService(),
        onComplete: @escaping (PetProfile) -> Void = { _ in }
    ) {
        self.session = session
        self.repository = repository
        self.service = service
        self.aiService = aiService
        self.onComplete = onComplete

        if let currentPetProfile = session.currentPetProfile {
            draft = PetProfileDraft(profile: currentPetProfile)
        } else if let currentUser = session.currentUser {
            Task {
                await loadExistingProfile(ownerUserID: currentUser.id)
            }
        }
    }

    var progressValue: Double {
        Double(currentStep.rawValue + 1) / Double(PetOnboardingStep.allCases.count)
    }

    var isOnLastStep: Bool {
        currentStep == .personality
    }

    func goBack() {
        errorMessage = nil
        successMessage = nil

        guard let previous = PetOnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previous
    }

    func continueOrSubmit() {
        errorMessage = nil
        successMessage = nil

        switch currentStep {
        case .identity:
            guard validateIdentityStep() else { return }
            currentStep = .details
        case .details:
            guard validateDetailsStep() else { return }
            currentStep = .personality
        case .personality:
            guard validatePersonalityStep() else { return }
            submit()
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

    func generateAIProfile(style: PetAIWritingStyle = .playful) {
        isGeneratingAI = true
        errorMessage = nil
        successMessage = nil

        let currentDraft = draft
        Task {
            do {
                let suggestion = try await aiService.generateProfileSuggestion(
                    from: currentDraft,
                    style: style
                )
                draft.bio = suggestion.bio
                draft.personalityTags = mergedTags(draft.personalityTags, suggestion.tags)
                isGeneratingAI = false
                successMessage = "AI drafted a pet voice. Tweak anything before saving."
            } catch {
                isGeneratingAI = false
                errorMessage = error.localizedDescription
            }
        }
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

    private func submit() {
        isSaving = true

        let finalDraft = draft

        Task {
            do {
                let createdProfile = try await service.createPetProfile(
                    draft: finalDraft,
                    ownerUserID: session.currentUser?.id
                )
                try await repository.upsertPetProfile(createdProfile)

                let resolvedAvatarURL = try await service.resolveAvatarURL(
                    for: createdProfile,
                    draft: finalDraft
                )
                let finalProfile = PetProfile(
                    id: createdProfile.id,
                    ownerUserID: createdProfile.ownerUserID,
                    name: createdProfile.name,
                    username: createdProfile.username,
                    avatarURL: resolvedAvatarURL,
                    petType: createdProfile.petType,
                    breed: createdProfile.breed,
                    age: createdProfile.age,
                    gender: createdProfile.gender,
                    bio: createdProfile.bio,
                    personalityTags: createdProfile.personalityTags,
                    createdAt: createdProfile.createdAt
                )

                if resolvedAvatarURL != createdProfile.avatarURL {
                    try await repository.upsertPetProfile(finalProfile)
                }

                await session.refreshCurrentPetProfile()

                isSaving = false
                if let refreshedProfile = session.currentPetProfile {
                    successMessage = "@\(refreshedProfile.username) is ready for the feed."
                    onComplete(refreshedProfile)
                } else {
                    session.completeOnboarding(with: finalProfile)
                    successMessage = "@\(finalProfile.username) is ready for the feed."
                    onComplete(finalProfile)
                }
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
            }
        }
    }

    private func validateIdentityStep() -> Bool {
        let trimmedName = draft.petName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHandle = draft.petHandle.trimmingCharacters(in: .whitespacesAndNewlines)

        if let validationMessage = PetSocialValidation.validatePetName(trimmedName) {
            errorMessage = validationMessage
            return false
        }

        if let validationMessage = PetSocialValidation.validateHandle(trimmedHandle) {
            errorMessage = validationMessage
            return false
        }

        draft.petHandle = PetSocialValidation.normalizedHandle(trimmedHandle)
        return true
    }

    private func validateDetailsStep() -> Bool {
        guard !draft.breed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Add a breed or type detail."
            return false
        }

        let trimmedAge = draft.age.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAge.isEmpty else {
            errorMessage = "Add an age so the profile feels complete."
            return false
        }

        if let validationMessage = PetSocialValidation.validateAge(trimmedAge) {
            errorMessage = validationMessage
            return false
        }

        return true
    }

    private func validatePersonalityStep() -> Bool {
        if !draft.pendingTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            addPendingTag()
        }

        if let validationMessage = PetSocialValidation.validateBio(draft.bio) {
            errorMessage = validationMessage
            return false
        }

        guard !draft.personalityTags.isEmpty else {
            errorMessage = "Add at least one personality tag."
            return false
        }

        return true
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

    private func loadExistingProfile(ownerUserID: String) async {
        guard let existingProfile = try? await repository.fetchPetProfile(ownerUserID: ownerUserID) else {
            return
        }

        draft = PetProfileDraft(profile: existingProfile)
    }
}
