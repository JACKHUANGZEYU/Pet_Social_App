import Foundation

struct SupabaseConfiguration: Hashable, Sendable {
    let url: URL
    let publishableKey: String
    let schema: String
    let petProfilesTable: String
    let postsTable: String
    let followsTable: String
    let mediaBucket: String
    let avatarPathPrefix: String
    let postsPathPrefix: String

    init(
        url: URL,
        publishableKey: String,
        schema: String = "public",
        petProfilesTable: String = SupabaseTable.petProfiles,
        postsTable: String = SupabaseTable.posts,
        followsTable: String = SupabaseTable.follows,
        mediaBucket: String = SupabaseTable.mediaBucket,
        avatarPathPrefix: String = "avatars",
        postsPathPrefix: String = "posts"
    ) {
        self.url = url
        self.publishableKey = publishableKey
        self.schema = schema
        self.petProfilesTable = petProfilesTable
        self.postsTable = postsTable
        self.followsTable = followsTable
        self.mediaBucket = mediaBucket
        self.avatarPathPrefix = avatarPathPrefix
        self.postsPathPrefix = postsPathPrefix
    }
}
