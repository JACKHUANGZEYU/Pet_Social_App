import Foundation

public actor MockPetSocialRepository: PetSocialRepository {
    private var petProfiles: [PetProfile]
    private var posts: [Post]
    private var followRelations: [FollowRelation]

    public init(
        petProfiles: [PetProfile] = MockSeedData.petProfiles,
        posts: [Post] = MockSeedData.posts,
        followRelations: [FollowRelation] = MockSeedData.followRelations
    ) {
        self.petProfiles = petProfiles
        self.posts = posts
        self.followRelations = followRelations
    }

    public func fetchPetProfile(id: String) async throws -> PetProfile? {
        petProfiles.first(where: { $0.id == id })
    }

    public func fetchPetProfile(ownerUserID: String) async throws -> PetProfile? {
        petProfiles.first(where: { $0.ownerUserID == ownerUserID })
    }

    public func fetchPetProfile(username: String) async throws -> PetProfile? {
        petProfiles.first(where: { $0.username.caseInsensitiveCompare(username) == .orderedSame })
    }

    public func fetchFeed(for petID: String) async throws -> [Post] {
        let followedPetIDs = followRelations
            .filter { $0.followerPetID == petID }
            .map(\.followingPetID)

        return posts
            .filter { $0.petID == petID || followedPetIDs.contains($0.petID) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func fetchPosts(for petID: String) async throws -> [Post] {
        posts
            .filter { $0.petID == petID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func fetchExplorePets(query: String?) async throws -> [PetProfile] {
        guard let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return petProfiles.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }

        return petProfiles.filter { profile in
            profile.name.localizedCaseInsensitiveContains(query)
                || profile.username.localizedCaseInsensitiveContains(query)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    public func fetchFollowerCount(for petID: String) async throws -> Int {
        followRelations.filter { $0.followingPetID == petID }.count
    }

    public func fetchFollowingCount(for petID: String) async throws -> Int {
        followRelations.filter { $0.followerPetID == petID }.count
    }

    public func isFollowing(followerPetID: String, followingPetID: String) async throws -> Bool {
        followRelations.contains {
            $0.followerPetID == followerPetID && $0.followingPetID == followingPetID
        }
    }

    public func upsertPetProfile(_ profile: PetProfile) async throws {
        if let existingIndex = petProfiles.firstIndex(where: { $0.id == profile.id || $0.ownerUserID == profile.ownerUserID }) {
            petProfiles[existingIndex] = profile
        } else {
            petProfiles.append(profile)
        }
    }

    public func createPost(_ post: Post) async throws {
        posts.append(post)
    }

    public func deletePost(id: String, requestingPetID: String) async throws {
        posts.removeAll { post in
            post.id == id && post.petID == requestingPetID
        }
    }

    public func toggleFollow(followerPetID: String, followingPetID: String) async throws -> Bool {
        if let existingIndex = followRelations.firstIndex(where: {
            $0.followerPetID == followerPetID && $0.followingPetID == followingPetID
        }) {
            followRelations.remove(at: existingIndex)
            return false
        }

        followRelations.append(
            FollowRelation(
                followerPetID: followerPetID,
                followingPetID: followingPetID
            )
        )
        return true
    }
}
