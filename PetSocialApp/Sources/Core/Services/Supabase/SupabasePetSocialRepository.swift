import Foundation

#if canImport(Supabase)
import Supabase

actor SupabasePetSocialRepository: PetSocialRepository {
    private let client: SupabaseClient
    private let configuration: SupabaseConfiguration

    init(client: SupabaseClient, configuration: SupabaseConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    func fetchPetProfile(id: String) async throws -> PetProfile? {
        let rows: [SupabasePetProfileRow] = try await client
            .from(configuration.petProfilesTable)
            .select()
            .eq("id", value: id)
            .execute()
            .value

        return rows.first.map { row in
            SupabaseDomainMapper.petProfile(from: row, publicURLBuilder: publicURL(for:))
        }
    }

    func fetchPetProfile(ownerUserID: String) async throws -> PetProfile? {
        let rows: [SupabasePetProfileRow] = try await client
            .from(configuration.petProfilesTable)
            .select()
            .eq("owner_user_id", value: ownerUserID)
            .execute()
            .value

        return rows.first.map { row in
            SupabaseDomainMapper.petProfile(from: row, publicURLBuilder: publicURL(for:))
        }
    }

    func fetchPetProfile(username: String) async throws -> PetProfile? {
        let rows: [SupabasePetProfileRow] = try await client
            .from(configuration.petProfilesTable)
            .select()
            .eq("pet_handle", value: username)
            .execute()
            .value

        return rows.first.map { row in
            SupabaseDomainMapper.petProfile(from: row, publicURLBuilder: publicURL(for:))
        }
    }

    func fetchFeed(for petID: String) async throws -> [Post] {
        let followRows: [SupabaseFollowRow] = try await client
            .from(configuration.followsTable)
            .select()
            .eq("follower_pet_id", value: petID)
            .execute()
            .value

        let followedIDs = Set(followRows.map(\.followingPetID) + [petID])
        let postRows: [SupabasePostRow] = try await client
            .from(configuration.postsTable)
            .select()
            .execute()
            .value

        return postRows
            .filter { followedIDs.contains($0.petID) }
            .sorted { $0.createdAt > $1.createdAt }
            .map { row in
                SupabaseDomainMapper.post(from: row, publicURLBuilder: publicURL(for:))
            }
    }

    func fetchPosts(for petID: String) async throws -> [Post] {
        let postRows: [SupabasePostRow] = try await client
            .from(configuration.postsTable)
            .select()
            .eq("pet_id", value: petID)
            .execute()
            .value

        return postRows
            .sorted { $0.createdAt > $1.createdAt }
            .map { row in
                SupabaseDomainMapper.post(from: row, publicURLBuilder: publicURL(for:))
            }
    }

    func fetchExplorePets(query: String?) async throws -> [PetProfile] {
        let rows: [SupabasePetProfileRow] = try await client
            .from(configuration.petProfilesTable)
            .select()
            .execute()
            .value

        let normalizedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

        return rows
            .filter { row in
                guard !normalizedQuery.isEmpty else { return true }
                return row.petName.lowercased().contains(normalizedQuery)
                    || row.petHandle.lowercased().contains(normalizedQuery)
            }
            .sorted { $0.petName.localizedCaseInsensitiveCompare($1.petName) == .orderedAscending }
            .map { row in
                SupabaseDomainMapper.petProfile(from: row, publicURLBuilder: publicURL(for:))
            }
    }

    func fetchFollowerCount(for petID: String) async throws -> Int {
        let rows: [SupabaseFollowRow] = try await client
            .from(configuration.followsTable)
            .select()
            .eq("following_pet_id", value: petID)
            .execute()
            .value

        return rows.count
    }

    func fetchFollowingCount(for petID: String) async throws -> Int {
        let rows: [SupabaseFollowRow] = try await client
            .from(configuration.followsTable)
            .select()
            .eq("follower_pet_id", value: petID)
            .execute()
            .value

        return rows.count
    }

    func isFollowing(followerPetID: String, followingPetID: String) async throws -> Bool {
        let rows: [SupabaseFollowRow] = try await client
            .from(configuration.followsTable)
            .select()
            .eq("follower_pet_id", value: followerPetID)
            .eq("following_pet_id", value: followingPetID)
            .execute()
            .value

        return !rows.isEmpty
    }

    func upsertPetProfile(_ profile: PetProfile) async throws {
        let existingProfile = try await fetchPetProfile(ownerUserID: profile.ownerUserID)
        let row = SupabaseDomainMapper.petProfileWriteRow(
            from: profile,
            existingID: existingProfile?.id,
            mediaBucket: configuration.mediaBucket
        )

        try await client
            .from(configuration.petProfilesTable)
            .upsert(row, onConflict: "owner_user_id")
            .execute()
    }

    func createPost(_ post: Post) async throws {
        let row = SupabaseDomainMapper.postWriteRow(
            from: post,
            mediaBucket: configuration.mediaBucket
        )

        try await client
            .from(configuration.postsTable)
            .insert(row)
            .execute()
    }

    func deletePost(id: String, requestingPetID: String) async throws {
        try await client
            .from(configuration.postsTable)
            .delete()
            .eq("id", value: id)
            .eq("pet_id", value: requestingPetID)
            .execute()
    }

    func toggleFollow(followerPetID: String, followingPetID: String) async throws -> Bool {
        let existingRows: [SupabaseFollowRow] = try await client
            .from(configuration.followsTable)
            .select()
            .eq("follower_pet_id", value: followerPetID)
            .eq("following_pet_id", value: followingPetID)
            .execute()
            .value

        if existingRows.isEmpty {
            try await client
                .from(configuration.followsTable)
                .insert(
                    SupabaseFollowWriteRow(
                        followerPetID: followerPetID,
                        followingPetID: followingPetID
                    )
                )
                .execute()
            return true
        }

        for row in existingRows {
            try await client
                .from(configuration.followsTable)
                .delete()
                .eq("id", value: row.id)
                .execute()
        }

        return false
    }

    private func publicURL(for assetPath: String?) -> URL? {
        guard let assetPath, !assetPath.isEmpty else { return nil }

        if assetPath.hasPrefix("http://") || assetPath.hasPrefix("https://") {
            return URL(string: assetPath)
        }

        return try? client.storage
            .from(configuration.mediaBucket)
            .getPublicURL(path: assetPath)
    }
}
#endif
