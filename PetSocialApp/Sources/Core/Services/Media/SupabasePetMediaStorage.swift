import Foundation

#if canImport(Supabase)
import Supabase

actor SupabasePetMediaStorage: PetMediaStorage {
    private let client: SupabaseClient
    private let configuration: SupabaseConfiguration
    private let urlSession: URLSession

    init(
        client: SupabaseClient,
        configuration: SupabaseConfiguration,
        urlSession: URLSession = .shared
    ) {
        self.client = client
        self.configuration = configuration
        self.urlSession = urlSession
    }

    func resolveRemoteImageURL(from rawValue: String?, kind: PetMediaKind) async throws -> URL? {
        guard let trimmed = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }

        guard let sourceURL = URL(string: trimmed) else {
            throw PetMediaStorageError.invalidURL
        }

        if isManagedSupabaseURL(sourceURL) {
            return sourceURL
        }

        let (data, response) = try await urlSession.data(from: sourceURL)
        guard !data.isEmpty else {
            throw PetMediaStorageError.downloadFailed
        }

        let contentType = inferredContentType(from: response, sourceURL: sourceURL)
        let fileExtension = inferredFileExtension(from: sourceURL, contentType: contentType)

        return try await upload(
            data: data,
            kind: kind,
            contentType: contentType,
            fileExtension: fileExtension
        )
    }

    func uploadPickedImage(_ asset: PickedImageAsset, kind: PetMediaKind) async throws -> URL {
        try await upload(
            data: asset.data,
            kind: kind,
            contentType: asset.mimeType,
            fileExtension: asset.fileExtension
        )
    }

    private func upload(
        data: Data,
        kind: PetMediaKind,
        contentType: String,
        fileExtension: String
    ) async throws -> URL {
        let path = buildPath(for: kind, fileExtension: fileExtension)
        try await client.storage
            .from(configuration.mediaBucket)
            .upload(
                path: path,
                file: data,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: contentType,
                    upsert: true
                )
            )

        return try client.storage
            .from(configuration.mediaBucket)
            .getPublicURL(path: path)
    }

    private func isManagedSupabaseURL(_ url: URL) -> Bool {
        guard let host = configuration.url.host else { return false }
        let absoluteString = url.absoluteString
        return absoluteString.contains(host) && absoluteString.contains(configuration.mediaBucket)
    }

    private func buildPath(for kind: PetMediaKind, fileExtension: String) -> String {
        switch kind {
        case .avatar(let profileID):
            return "\(profileID.lowercased())/\(configuration.avatarPathPrefix)/avatar.\(fileExtension)"
        case .post(let petID, let postID):
            return "\(petID.lowercased())/\(configuration.postsPathPrefix)/\(postID.lowercased()).\(fileExtension)"
        }
    }

    private func inferredContentType(from response: URLResponse, sourceURL: URL) -> String {
        if let mimeType = response.mimeType, mimeType.hasPrefix("image/") {
            return mimeType
        }

        switch sourceURL.pathExtension.lowercased() {
        case "png":
            return "image/png"
        case "webp":
            return "image/webp"
        case "heic", "heif":
            return "image/heic"
        default:
            return "image/jpeg"
        }
    }

    private func inferredFileExtension(from sourceURL: URL, contentType: String) -> String {
        let sourceExtension = sourceURL.pathExtension.lowercased()
        if !sourceExtension.isEmpty {
            return sourceExtension
        }

        switch contentType {
        case "image/png":
            return "png"
        case "image/webp":
            return "webp"
        case "image/heic":
            return "heic"
        default:
            return "jpg"
        }
    }
}
#endif
