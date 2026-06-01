import Combine
import Foundation

@MainActor
final class PetAIStudioViewModel: ObservableObject {
    @Published var focus = ""
    @Published var selectedStyle: PetAIWritingStyle = .playful
    @Published private(set) var studioPack: PetAIStudioPack?
    @Published private(set) var isGenerating = false
    @Published private(set) var statusMessage: String?

    private let session: AppSessionStore
    private let aiService: any PetAIService

    init(
        session: AppSessionStore,
        aiService: any PetAIService
    ) {
        self.session = session
        self.aiService = aiService
    }

    var currentPet: PetProfile? {
        session.currentPetProfile
    }

    func generateStudioPack() {
        guard let currentPet else {
            statusMessage = PetAIError.missingPet.localizedDescription
            return
        }

        isGenerating = true
        statusMessage = nil

        let currentFocus = focus
        let currentStyle = selectedStyle
        Task {
            do {
                studioPack = try await aiService.generateStudioPack(
                    for: currentPet,
                    focus: currentFocus,
                    style: currentStyle
                )
                isGenerating = false
                statusMessage = "AI Studio refreshed ideas for \(currentPet.name)."
            } catch {
                isGenerating = false
                statusMessage = error.localizedDescription
            }
        }
    }
}
