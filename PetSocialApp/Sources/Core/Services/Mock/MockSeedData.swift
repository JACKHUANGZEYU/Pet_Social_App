import Foundation

public enum MockSeedData {
    public static let defaultUserID = "user.demo.alex"

    public static let users: [AppUser] = [
        AppUser(
            id: "user.demo.alex",
            email: "alex@example.com",
            displayName: "Alex",
            createdAt: Date(timeIntervalSince1970: 1_712_190_000)
        ),
        AppUser(
            id: "user.demo.jamie",
            email: "jamie@example.com",
            displayName: "Jamie",
            createdAt: Date(timeIntervalSince1970: 1_712_276_400)
        ),
        AppUser(
            id: "user.demo.sam",
            email: "sam@example.com",
            displayName: "Sam",
            createdAt: Date(timeIntervalSince1970: 1_712_362_800)
        )
    ]

    public static let petProfiles: [PetProfile] = [
        PetProfile(
            id: "pet.mochi",
            ownerUserID: "user.demo.alex",
            name: "Mochi",
            username: "mochi_the_corgi",
            avatarURL: URL(string: "https://images.unsplash.com/photo-1548199973-03cce0bbc87b"),
            petType: .dog,
            breed: "Pembroke Welsh Corgi",
            age: 3,
            gender: .female,
            bio: "Tiny legs, huge opinions, always scouting for snacks.",
            personalityTags: ["playful", "foodie", "dramatic"],
            createdAt: Date(timeIntervalSince1970: 1_712_190_000)
        ),
        PetProfile(
            id: "pet.luna",
            ownerUserID: "user.demo.jamie",
            name: "Luna",
            username: "luna_naps_daily",
            avatarURL: URL(string: "https://images.unsplash.com/photo-1519052537078-e6302a4968d4"),
            petType: .cat,
            breed: "British Shorthair",
            age: 4,
            gender: .female,
            bio: "Professional sunbeam hunter and couch philosopher.",
            personalityTags: ["sleepy", "elegant", "judgmental"],
            createdAt: Date(timeIntervalSince1970: 1_712_276_400)
        ),
        PetProfile(
            id: "pet.bao",
            ownerUserID: "user.demo.sam",
            name: "Bao",
            username: "bao_zoomies",
            avatarURL: URL(string: "https://images.unsplash.com/photo-1525253086316-d0c936c814f8"),
            petType: .dog,
            breed: "Shiba Inu",
            age: 2,
            gender: .male,
            bio: "Here for park sprints, side-eyes, and suspicious leaves.",
            personalityTags: ["chaotic", "brave", "curious"],
            createdAt: Date(timeIntervalSince1970: 1_712_362_800)
        )
    ]

    public static let posts: [Post] = [
        Post(
            id: "post.mochi.1",
            petID: "pet.mochi",
            text: "Mom said this was a short walk. I disagree.",
            createdAt: Date(timeIntervalSince1970: 1_712_530_000)
        ),
        Post(
            id: "post.mochi.2",
            petID: "pet.mochi",
            text: "Rate my loaf form.",
            imageURL: URL(string: "https://images.unsplash.com/photo-1517849845537-4d257902454a"),
            createdAt: Date(timeIntervalSince1970: 1_712_616_400)
        ),
        Post(
            id: "post.luna.1",
            petID: "pet.luna",
            text: "Interrupted my 5th nap for this photo shoot.",
            imageURL: URL(string: "https://images.unsplash.com/photo-1511044568932-338cba0ad803"),
            createdAt: Date(timeIntervalSince1970: 1_712_702_800)
        ),
        Post(
            id: "post.bao.1",
            petID: "pet.bao",
            text: "Found a leaf. Chased the leaf. Lost the leaf.",
            createdAt: Date(timeIntervalSince1970: 1_712_789_200)
        ),
        Post(
            id: "post.bao.2",
            petID: "pet.bao",
            text: "Park report: 10/10 smells today.",
            imageURL: URL(string: "https://images.unsplash.com/photo-1507146426996-ef05306b995a"),
            createdAt: Date(timeIntervalSince1970: 1_712_875_600)
        )
    ]

    public static let followRelations: [FollowRelation] = [
        FollowRelation(
            id: "follow.mochi.luna",
            followerPetID: "pet.mochi",
            followingPetID: "pet.luna",
            createdAt: Date(timeIntervalSince1970: 1_712_910_000)
        ),
        FollowRelation(
            id: "follow.mochi.bao",
            followerPetID: "pet.mochi",
            followingPetID: "pet.bao",
            createdAt: Date(timeIntervalSince1970: 1_712_996_400)
        ),
        FollowRelation(
            id: "follow.luna.mochi",
            followerPetID: "pet.luna",
            followingPetID: "pet.mochi",
            createdAt: Date(timeIntervalSince1970: 1_713_082_800)
        )
    ]

    public static var defaultUser: AppUser {
        users.first(where: { $0.id == defaultUserID }) ?? users[0]
    }

    public static var defaultPetProfile: PetProfile {
        petProfiles.first(where: { $0.ownerUserID == defaultUserID }) ?? petProfiles[0]
    }
}
