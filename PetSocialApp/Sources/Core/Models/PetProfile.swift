import Foundation

public enum PetType: String, Codable, CaseIterable, Hashable, Sendable {
    case dog
    case cat
    case rabbit
    case bird
    case hamster
    case other
}

public enum PetGender: String, Codable, CaseIterable, Hashable, Sendable {
    case male
    case female
    case unknown
}

public struct PetProfile: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let ownerUserID: String
    public var name: String
    public var username: String
    public var avatarURL: URL?
    public var petType: PetType
    public var breed: String
    public var age: Int
    public var gender: PetGender
    public var bio: String
    public var personalityTags: [String]
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        ownerUserID: String,
        name: String,
        username: String,
        avatarURL: URL? = nil,
        petType: PetType,
        breed: String,
        age: Int,
        gender: PetGender,
        bio: String,
        personalityTags: [String],
        createdAt: Date = .now
    ) {
        self.id = id
        self.ownerUserID = ownerUserID
        self.name = name
        self.username = username
        self.avatarURL = avatarURL
        self.petType = petType
        self.breed = breed
        self.age = age
        self.gender = gender
        self.bio = bio
        self.personalityTags = personalityTags
        self.createdAt = createdAt
    }

    public var handle: String {
        "@\(username)"
    }
}
