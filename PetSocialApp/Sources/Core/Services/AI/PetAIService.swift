import Foundation

enum PetAIWritingStyle: String, CaseIterable, Identifiable, Codable, Sendable {
    case playful
    case cozy
    case sassy
    case poetic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .playful:
            return "Playful"
        case .cozy:
            return "Cozy"
        case .sassy:
            return "Sassy"
        case .poetic:
            return "Poetic"
        }
    }
}

struct PetAIProfileSuggestion: Codable, Equatable, Sendable {
    var bio: String
    var tags: [String]
}

struct PetAIStudioPack: Codable, Equatable, Sendable {
    var voiceSample: String
    var postIdeas: [String]
    var icebreakers: [String]
    var careReminders: [String]
}

enum PetAIError: LocalizedError {
    case missingPet
    case invalidProxyURL
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingPet:
            return "Create a pet profile before using AI helpers."
        case .invalidProxyURL:
            return "The AI proxy URL is invalid."
        case .emptyResponse:
            return "The AI helper did not return usable suggestions."
        }
    }
}

protocol PetAIService: Sendable {
    func generateProfileSuggestion(
        from draft: PetProfileDraft,
        style: PetAIWritingStyle
    ) async throws -> PetAIProfileSuggestion

    func polishProfile(
        profile: PetProfile,
        draft: PetProfileDraft,
        style: PetAIWritingStyle
    ) async throws -> PetAIProfileSuggestion

    func suggestPostCaptions(
        for pet: PetProfile,
        context: String,
        style: PetAIWritingStyle
    ) async throws -> [String]

    func generateStudioPack(
        for pet: PetProfile,
        focus: String,
        style: PetAIWritingStyle
    ) async throws -> PetAIStudioPack
}
