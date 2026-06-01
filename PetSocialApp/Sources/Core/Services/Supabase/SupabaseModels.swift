import Foundation

enum SupabaseTable {
    static let petProfiles = "pet_profiles"
    static let posts = "posts"
    static let follows = "follows"
    static let mediaBucket = "pet-media"
}

struct SupabasePetProfileRow: Codable {
    let id: String
    let ownerUserID: String
    let petName: String
    let petHandle: String
    let avatarPath: String?
    let petType: String
    let breed: String?
    let age: Int?
    let gender: String?
    let bio: String?
    let personalityTags: [String]
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case ownerUserID = "owner_user_id"
        case petName = "pet_name"
        case petHandle = "pet_handle"
        case avatarPath = "avatar_path"
        case petType = "pet_type"
        case breed
        case age
        case gender
        case bio
        case personalityTags = "personality_tags"
        case createdAt = "created_at"
    }
}

struct SupabasePetProfileWriteRow: Encodable {
    let id: String
    let ownerUserID: String
    let petName: String
    let petHandle: String
    let avatarPath: String?
    let petType: String
    let breed: String?
    let age: Int?
    let gender: String?
    let bio: String?
    let personalityTags: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case ownerUserID = "owner_user_id"
        case petName = "pet_name"
        case petHandle = "pet_handle"
        case avatarPath = "avatar_path"
        case petType = "pet_type"
        case breed
        case age
        case gender
        case bio
        case personalityTags = "personality_tags"
    }
}

struct SupabasePostRow: Codable {
    let id: String
    let petID: String
    let textContent: String?
    let imagePath: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case petID = "pet_id"
        case textContent = "text_content"
        case imagePath = "image_path"
        case createdAt = "created_at"
    }
}

struct SupabasePostWriteRow: Encodable {
    let id: String
    let petID: String
    let textContent: String?
    let imagePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case petID = "pet_id"
        case textContent = "text_content"
        case imagePath = "image_path"
    }
}

struct SupabaseFollowRow: Codable {
    let id: String
    let followerPetID: String
    let followingPetID: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case followerPetID = "follower_pet_id"
        case followingPetID = "following_pet_id"
        case createdAt = "created_at"
    }
}

struct SupabaseFollowWriteRow: Encodable {
    let followerPetID: String
    let followingPetID: String

    enum CodingKeys: String, CodingKey {
        case followerPetID = "follower_pet_id"
        case followingPetID = "following_pet_id"
    }
}

enum SupabaseDomainMapper {
    static func petProfile(from row: SupabasePetProfileRow, publicURLBuilder: (String?) -> URL?) -> PetProfile {
        PetProfile(
            id: row.id,
            ownerUserID: row.ownerUserID,
            name: row.petName,
            username: row.petHandle,
            avatarURL: publicURLBuilder(row.avatarPath),
            petType: PetType(rawValue: row.petType) ?? .other,
            breed: row.breed ?? "",
            age: row.age ?? 0,
            gender: PetGender(rawValue: row.gender ?? "unknown") ?? .unknown,
            bio: row.bio ?? "",
            personalityTags: row.personalityTags,
            createdAt: row.createdAt
        )
    }

    static func petProfileWriteRow(
        from profile: PetProfile,
        existingID: String? = nil,
        mediaBucket: String
    ) -> SupabasePetProfileWriteRow {
        SupabasePetProfileWriteRow(
            id: existingID ?? profile.id,
            ownerUserID: profile.ownerUserID,
            petName: profile.name,
            petHandle: profile.username,
            avatarPath: assetPath(from: profile.avatarURL, mediaBucket: mediaBucket),
            petType: profile.petType.rawValue,
            breed: profile.breed.isEmpty ? nil : profile.breed,
            age: profile.age,
            gender: profile.gender.rawValue,
            bio: profile.bio.isEmpty ? nil : profile.bio,
            personalityTags: profile.personalityTags
        )
    }

    static func post(from row: SupabasePostRow, publicURLBuilder: (String?) -> URL?) -> Post {
        Post(
            id: row.id,
            petID: row.petID,
            text: row.textContent,
            imageURL: publicURLBuilder(row.imagePath),
            createdAt: row.createdAt
        )
    }

    static func postWriteRow(from post: Post, mediaBucket: String) -> SupabasePostWriteRow {
        SupabasePostWriteRow(
            id: post.id,
            petID: post.petID,
            textContent: post.text,
            imagePath: assetPath(from: post.imageURL, mediaBucket: mediaBucket)
        )
    }

    private static func assetPath(from url: URL?, mediaBucket: String) -> String? {
        guard let url else { return nil }
        let absoluteString = url.absoluteString
        let marker = "/storage/v1/object/public/\(mediaBucket)/"

        guard let markerRange = absoluteString.range(of: marker) else {
            return absoluteString
        }

        return String(absoluteString[markerRange.upperBound...])
    }
}
