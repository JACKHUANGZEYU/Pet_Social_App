import Foundation

public struct AppUser: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var email: String
    public var displayName: String
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        email: String,
        displayName: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
    }
}
