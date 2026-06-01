import Combine
import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var authorsByID: [String: PetProfile] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var isDeletingPostID: String?
    @Published private(set) var errorMessage: String?

    private let session: AppSessionStore
    private let repository: any PetSocialRepository

    init(session: AppSessionStore, repository: any PetSocialRepository) {
        self.session = session
        self.repository = repository
    }

    func loadFeed() async {
        guard let currentPet = session.currentPetProfile else {
            posts = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let feedPosts = try await repository.fetchFeed(for: currentPet.id)
            var authorMap: [String: PetProfile] = [:]

            for post in feedPosts {
                if let profile = try await repository.fetchPetProfile(id: post.petID) {
                    authorMap[post.petID] = profile
                }
            }

            posts = feedPosts
            authorsByID = authorMap
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func canManagePost(_ post: Post) -> Bool {
        post.petID == session.currentPetProfile?.id
    }

    func deletePost(_ post: Post) {
        guard canManagePost(post),
              let currentPetID = session.currentPetProfile?.id else {
            return
        }

        isDeletingPostID = post.id
        errorMessage = nil

        Task {
            do {
                try await repository.deletePost(id: post.id, requestingPetID: currentPetID)
                posts.removeAll { $0.id == post.id }
                isDeletingPostID = nil
            } catch {
                errorMessage = error.localizedDescription
                isDeletingPostID = nil
            }
        }
    }
}
