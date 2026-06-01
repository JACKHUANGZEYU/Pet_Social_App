import Foundation

struct MockPetAIService: PetAIService {
    func generateProfileSuggestion(
        from draft: PetProfileDraft,
        style: PetAIWritingStyle
    ) async throws -> PetAIProfileSuggestion {
        try await Task.sleep(nanoseconds: 350_000_000)

        let name = friendlyName(draft.petName)
        let breed = draft.breed.trimmingCharacters(in: .whitespacesAndNewlines)
        let type = draft.petType.rawValue
        let bio = "\(name) is a \(styleAdjective(style)) \(breed.isEmpty ? type : breed) with tiny rituals, big feelings, and a heroic commitment to snack research."

        return PetAIProfileSuggestion(
            bio: bio,
            tags: uniqueTags([
                styleTag(style),
                "snack-driven",
                type == "cat" ? "sunbeam critic" : "park reporter",
                "main-character"
            ])
        )
    }

    func polishProfile(
        profile: PetProfile,
        draft: PetProfileDraft,
        style: PetAIWritingStyle
    ) async throws -> PetAIProfileSuggestion {
        try await Task.sleep(nanoseconds: 350_000_000)

        let name = friendlyName(draft.petName.isEmpty ? profile.name : draft.petName)
        let existingBio = draft.bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let bioSeed = existingBio.isEmpty ? "\(name) is still deciding what the neighborhood should know." : existingBio

        return PetAIProfileSuggestion(
            bio: "\(name)'s official dispatch: \(bioSeed) Also accepting compliments, gentle chaos, and premium treats.",
            tags: uniqueTags(draft.personalityTags + [styleTag(style), "petfluencer", "curious"])
        )
    }

    func suggestPostCaptions(
        for pet: PetProfile,
        context: String,
        style: PetAIWritingStyle
    ) async throws -> [String] {
        try await Task.sleep(nanoseconds: 300_000_000)

        let topic = context.trimmingCharacters(in: .whitespacesAndNewlines)
        let scene = topic.isEmpty ? "today's extremely important pet business" : topic

        return [
            "\(pet.name) reporting live: \(scene). I have sniffed the evidence and require snacks.",
            "Small update from \(pet.handle): \(scene). Very serious. Very fluffy.",
            "If anyone needs me, I will be turning \(scene) into my whole personality."
        ]
    }

    func generateStudioPack(
        for pet: PetProfile,
        focus: String,
        style: PetAIWritingStyle
    ) async throws -> PetAIStudioPack {
        try await Task.sleep(nanoseconds: 450_000_000)

        let topic = focus.trimmingCharacters(in: .whitespacesAndNewlines)
        let focusLine = topic.isEmpty ? "daily pet life" : topic

        return PetAIStudioPack(
            voiceSample: "\(pet.name) speaks in \(style.displayName.lowercased()) little field notes: dramatic pauses, snack optimism, and one suspicious glance at every vacuum.",
            postIdeas: [
                "A morning patrol report about \(focusLine)",
                "A tiny review of the best nap spot in the home",
                "A before-and-after story: calm pet versus treat bag sound"
            ],
            icebreakers: [
                "What is your pet's most unnecessary daily ritual?",
                "Which toy has achieved legendary status in your home?",
                "What would your pet write in a neighborhood newsletter?"
            ],
            careReminders: [
                "Add a recent photo before posting so followers connect with the moment.",
                "Keep captions short, pet-first, and easy to react to.",
                "Rotate between funny posts, routine updates, and gentle owner context."
            ]
        )
    }

    private func friendlyName(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Your pet" : trimmed
    }

    private func styleAdjective(_ style: PetAIWritingStyle) -> String {
        switch style {
        case .playful:
            return "mischievous"
        case .cozy:
            return "soft-hearted"
        case .sassy:
            return "opinionated"
        case .poetic:
            return "moonlit"
        }
    }

    private func styleTag(_ style: PetAIWritingStyle) -> String {
        switch style {
        case .playful:
            return "playful"
        case .cozy:
            return "cozy"
        case .sassy:
            return "sassy"
        case .poetic:
            return "dreamy"
        }
    }

    private func uniqueTags(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        return tags
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { tag in
                guard !tag.isEmpty, !seen.contains(tag) else { return false }
                seen.insert(tag)
                return true
            }
            .prefix(6)
            .map(String.init)
    }
}
