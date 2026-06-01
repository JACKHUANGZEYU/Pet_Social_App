import Foundation

actor RemotePetAIService: PetAIService {
    private let endpointURL: URL
    private let urlSession: URLSession
    private let fallback = MockPetAIService()

    init(proxyBaseURL: URL, urlSession: URLSession = .shared) {
        self.endpointURL = proxyBaseURL.appending(path: "pet-ai/generate")
        self.urlSession = urlSession
    }

    func generateProfileSuggestion(
        from draft: PetProfileDraft,
        style: PetAIWritingStyle
    ) async throws -> PetAIProfileSuggestion {
        let response = try await send(
            PetAIProxyRequest(
                feature: .profileSuggestion,
                pet: .init(draft: draft),
                style: style,
                context: nil
            )
        )

        if let profileSuggestion = response.profileSuggestion {
            return profileSuggestion
        }

        return try await fallback.generateProfileSuggestion(from: draft, style: style)
    }

    func polishProfile(
        profile: PetProfile,
        draft: PetProfileDraft,
        style: PetAIWritingStyle
    ) async throws -> PetAIProfileSuggestion {
        let response = try await send(
            PetAIProxyRequest(
                feature: .profilePolish,
                pet: .init(profile: profile, draft: draft),
                style: style,
                context: draft.bio
            )
        )

        if let profileSuggestion = response.profileSuggestion {
            return profileSuggestion
        }

        return try await fallback.polishProfile(profile: profile, draft: draft, style: style)
    }

    func suggestPostCaptions(
        for pet: PetProfile,
        context: String,
        style: PetAIWritingStyle
    ) async throws -> [String] {
        let response = try await send(
            PetAIProxyRequest(
                feature: .postCaptions,
                pet: .init(profile: pet),
                style: style,
                context: context
            )
        )

        if let captions = response.captions, !captions.isEmpty {
            return captions
        }

        return try await fallback.suggestPostCaptions(for: pet, context: context, style: style)
    }

    func generateStudioPack(
        for pet: PetProfile,
        focus: String,
        style: PetAIWritingStyle
    ) async throws -> PetAIStudioPack {
        let response = try await send(
            PetAIProxyRequest(
                feature: .studioPack,
                pet: .init(profile: pet),
                style: style,
                context: focus
            )
        )

        if let studioPack = response.studioPack {
            return studioPack
        }

        return try await fallback.generateStudioPack(for: pet, focus: focus, style: style)
    }

    private func send(_ payload: PetAIProxyRequest) async throws -> PetAIProxyResponse {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PetAIError.emptyResponse
        }

        return try JSONDecoder().decode(PetAIProxyResponse.self, from: data)
    }
}

private enum PetAIProxyFeature: String, Codable {
    case profileSuggestion
    case profilePolish
    case postCaptions
    case studioPack
}

private struct PetAIProxyRequest: Codable {
    let feature: PetAIProxyFeature
    let pet: PetAIProxyPetContext
    let style: PetAIWritingStyle
    let context: String?
}

private struct PetAIProxyPetContext: Codable {
    let id: String?
    let name: String
    let handle: String?
    let petType: String
    let breed: String
    let age: Int?
    let gender: String
    let bio: String
    let personalityTags: [String]

    init(draft: PetProfileDraft) {
        self.id = nil
        self.name = draft.petName
        self.handle = draft.petHandle
        self.petType = draft.petType.rawValue
        self.breed = draft.breed
        self.age = Int(draft.age.trimmingCharacters(in: .whitespacesAndNewlines))
        self.gender = draft.gender.rawValue
        self.bio = draft.bio
        self.personalityTags = draft.personalityTags
    }

    init(profile: PetProfile) {
        self.id = profile.id
        self.name = profile.name
        self.handle = profile.username
        self.petType = profile.petType.rawValue
        self.breed = profile.breed
        self.age = profile.age
        self.gender = profile.gender.rawValue
        self.bio = profile.bio
        self.personalityTags = profile.personalityTags
    }

    init(profile: PetProfile, draft: PetProfileDraft) {
        self.id = profile.id
        self.name = draft.petName
        self.handle = draft.petHandle
        self.petType = draft.petType.rawValue
        self.breed = draft.breed
        self.age = Int(draft.age.trimmingCharacters(in: .whitespacesAndNewlines))
        self.gender = draft.gender.rawValue
        self.bio = draft.bio
        self.personalityTags = draft.personalityTags
    }
}

private struct PetAIProxyResponse: Codable {
    let profileSuggestion: PetAIProfileSuggestion?
    let captions: [String]?
    let studioPack: PetAIStudioPack?
}
