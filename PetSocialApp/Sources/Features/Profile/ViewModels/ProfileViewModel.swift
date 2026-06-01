import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var petProfile: PetProfile?
    @Published private(set) var posts: [Post] = []
    @Published private(set) var followerCount = 0
    @Published private(set) var followingCount = 0
    @Published private(set) var isFollowing = false
    @Published private(set) var isLoading = false
    @Published private(set) var isTogglingFollow = false
    @Published private(set) var isDeletingPostID: String?
    @Published private(set) var errorMessage: String?

    private let session: AppSessionStore
    private let repository: any PetSocialRepository
    private let selectedPetID: String?

    init(session: AppSessionStore, repository: any PetSocialRepository, selectedPetID: String? = nil) {
        self.session = session
        self.repository = repository
        self.selectedPetID = selectedPetID
    }

    var isViewingCurrentPet: Bool {
        petProfile?.id == session.currentPetProfile?.id
    }

    func loadProfile() async {
        guard let targetPetID = selectedPetID ?? session.currentPetProfile?.id else { return }

        isLoading = true
        petProfile = try? await repository.fetchPetProfile(id: targetPetID)

        guard let petProfile else {
            posts = []
            followerCount = 0
            followingCount = 0
            isFollowing = false
            isLoading = false
            return
        }

        posts = (try? await repository.fetchPosts(for: petProfile.id)) ?? []
        followerCount = (try? await repository.fetchFollowerCount(for: petProfile.id)) ?? 0
        followingCount = (try? await repository.fetchFollowingCount(for: petProfile.id)) ?? 0

        if let currentPetID = session.currentPetProfile?.id, currentPetID != petProfile.id {
            isFollowing = (try? await repository.isFollowing(
                followerPetID: currentPetID,
                followingPetID: petProfile.id
            )) ?? false
        } else {
            isFollowing = false
        }

        isLoading = false
    }

    func toggleFollow() {
        guard let currentPetID = session.currentPetProfile?.id,
              let viewedPetID = petProfile?.id,
              currentPetID != viewedPetID else {
            return
        }

        isTogglingFollow = true
        errorMessage = nil

        Task {
            do {
                _ = try await repository.toggleFollow(
                    followerPetID: currentPetID,
                    followingPetID: viewedPetID
                )
                await loadProfile()
                isTogglingFollow = false
            } catch {
                errorMessage = error.localizedDescription
                isTogglingFollow = false
            }
        }
    }

    func deletePost(_ post: Post) {
        guard isViewingCurrentPet,
              let currentPetID = session.currentPetProfile?.id,
              post.petID == currentPetID else {
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
