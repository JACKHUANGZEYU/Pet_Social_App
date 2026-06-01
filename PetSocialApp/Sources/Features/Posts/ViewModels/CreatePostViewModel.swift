import Combine
import Foundation

@MainActor
final class CreatePostViewModel: ObservableObject {
    @Published var text = ""
    @Published var imageURL = ""
    @Published private(set) var pickedImageAsset: PickedImageAsset?
    @Published private(set) var isPosting = false
    @Published private(set) var isGeneratingAI = false
    @Published private(set) var aiCaptions: [String] = []
    @Published private(set) var statusMessage: String?

    private let session: AppSessionStore
    private let repository: any PetSocialRepository
    private let mediaStorage: any PetMediaStorage
    private let aiService: any PetAIService

    init(
        session: AppSessionStore,
        repository: any PetSocialRepository,
        mediaStorage: any PetMediaStorage = MockPetMediaStorage(),
        aiService: any PetAIService = MockPetAIService()
    ) {
        self.session = session
        self.repository = repository
        self.mediaStorage = mediaStorage
        self.aiService = aiService
    }

    func applyPickedImageAsset(_ asset: PickedImageAsset?) {
        pickedImageAsset = asset
        if asset != nil {
            imageURL = ""
        }
    }

    func remoteImageURLDidChange() {
        if !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            pickedImageAsset = nil
        }
    }

    func generateAICaptions(style: PetAIWritingStyle = .playful) {
        guard let pet = session.currentPetProfile else {
            statusMessage = PetAIError.missingPet.localizedDescription
            return
        }

        isGeneratingAI = true
        statusMessage = nil

        let context = text.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            do {
                aiCaptions = try await aiService.suggestPostCaptions(
                    for: pet,
                    context: context,
                    style: style
                )
                isGeneratingAI = false
                statusMessage = "AI suggested \(aiCaptions.count) pet-style captions."
            } catch {
                isGeneratingAI = false
                statusMessage = error.localizedDescription
            }
        }
    }

    func applyAICaption(_ caption: String) {
        text = caption
        statusMessage = "Caption applied. Add a photo or publish when ready."
    }

    func submitPost() {
        guard let currentPetID = session.currentPetProfile?.id else {
            statusMessage = "Create your pet profile before posting."
            return
        }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedImageURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)

        if let validationMessage = PetSocialValidation.validatePostText(trimmedText) {
            statusMessage = validationMessage
            return
        }

        guard !trimmedText.isEmpty || !trimmedImageURL.isEmpty || pickedImageAsset != nil else {
            statusMessage = "Add a caption, paste an image URL, or choose a photo."
            return
        }

        isPosting = true
        statusMessage = nil

        Task {
            do {
                let draftPost = Post(
                    petID: currentPetID,
                    text: trimmedText.isEmpty ? nil : trimmedText,
                    imageURL: nil
                )
                let resolvedImageURL: URL?
                if let pickedImageAsset {
                    resolvedImageURL = try await mediaStorage.uploadPickedImage(
                        pickedImageAsset,
                        kind: .post(petID: currentPetID, postID: draftPost.id)
                    )
                } else {
                    resolvedImageURL = try await mediaStorage.resolveRemoteImageURL(
                        from: trimmedImageURL,
                        kind: .post(petID: currentPetID, postID: draftPost.id)
                    )
                }
                try await repository.createPost(
                    Post(
                        id: draftPost.id,
                        petID: currentPetID,
                        text: draftPost.text,
                        imageURL: resolvedImageURL,
                        createdAt: draftPost.createdAt
                    )
                )
                text = ""
                imageURL = ""
                pickedImageAsset = nil
                aiCaptions = []
                statusMessage = "Post published to the feed."
                isPosting = false
            } catch {
                statusMessage = error.localizedDescription
                isPosting = false
            }
        }
    }
}
