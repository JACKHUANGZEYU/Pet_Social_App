import Foundation

public struct Post: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let petID: String
    public var text: String?
    public var imageURL: URL?
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        petID: String,
        text: String? = nil,
        imageURL: URL? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.petID = petID
        self.text = text
        self.imageURL = imageURL
        self.createdAt = createdAt
    }

    public var hasImage: Bool {
        imageURL != nil
    }
}

public typealias PetPost = Post
