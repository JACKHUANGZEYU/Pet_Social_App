import Foundation

public protocol PetSocialRepository: Sendable {
    func fetchPetProfile(id: String) async throws -> PetProfile?
    func fetchPetProfile(ownerUserID: String) async throws -> PetProfile?
    func fetchPetProfile(username: String) async throws -> PetProfile?
    func fetchFeed(for petID: String) async throws -> [Post]
    func fetchPosts(for petID: String) async throws -> [Post]
    func fetchExplorePets(query: String?) async throws -> [PetProfile]
    func fetchFollowerCount(for petID: String) async throws -> Int
    func fetchFollowingCount(for petID: String) async throws -> Int
    func isFollowing(followerPetID: String, followingPetID: String) async throws -> Bool
    func upsertPetProfile(_ profile: PetProfile) async throws
    func createPost(_ post: Post) async throws
    func deletePost(id: String, requestingPetID: String) async throws
    func toggleFollow(followerPetID: String, followingPetID: String) async throws -> Bool
}
