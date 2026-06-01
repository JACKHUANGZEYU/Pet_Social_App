import Foundation

public struct FollowRelation: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let followerPetID: String
    public let followingPetID: String
    public let createdAt: Date

    public init(
        id: String = UUID().uuidString,
        followerPetID: String,
        followingPetID: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.followerPetID = followerPetID
        self.followingPetID = followingPetID
        self.createdAt = createdAt
    }
}
