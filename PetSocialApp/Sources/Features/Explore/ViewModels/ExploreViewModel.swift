import Combine
import Foundation

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var pets: [PetProfile] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let session: AppSessionStore
    private let repository: any PetSocialRepository
    private var searchTask: Task<Void, Never>?

    init(session: AppSessionStore, repository: any PetSocialRepository) {
        self.session = session
        self.repository = repository
    }

    func loadExplore() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedPets = try await repository.fetchExplorePets(query: query)
            let currentPetID = session.currentPetProfile?.id
            pets = fetchedPets.filter { $0.id != currentPetID }
            isLoading = false
        } catch {
            pets = []
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await self?.loadExplore()
        }
    }
}
