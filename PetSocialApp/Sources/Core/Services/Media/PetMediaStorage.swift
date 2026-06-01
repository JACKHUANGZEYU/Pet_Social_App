import Foundation

enum PetMediaKind: Sendable {
    case avatar(profileID: String)
    case post(petID: String, postID: String)
}

enum PetMediaStorageError: LocalizedError {
    case invalidURL
    case downloadFailed
    case unsupportedResponse
    case fileWriteFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The media URL is invalid."
        case .downloadFailed:
            return "The media file could not be downloaded."
        case .unsupportedResponse:
            return "The media response was not a supported image."
        case .fileWriteFailed:
            return "The local media file could not be prepared."
        }
    }
}

protocol PetMediaStorage: Sendable {
    func resolveRemoteImageURL(from rawValue: String?, kind: PetMediaKind) async throws -> URL?
    func uploadPickedImage(_ asset: PickedImageAsset, kind: PetMediaKind) async throws -> URL
}

struct MockPetMediaStorage: PetMediaStorage {
    func resolveRemoteImageURL(from rawValue: String?, kind _: PetMediaKind) async throws -> URL? {
        guard let trimmed = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }

        guard let url = URL(string: trimmed) else {
            throw PetMediaStorageError.invalidURL
        }

        return url
    }

    func uploadPickedImage(_ asset: PickedImageAsset, kind: PetMediaKind) async throws -> URL {
        let fileManager = FileManager.default
        let fileURL = fileManager.temporaryDirectory.appendingPathComponent(
            pathComponent(for: kind, fileExtension: asset.fileExtension)
        )

        do {
            try asset.data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            throw PetMediaStorageError.fileWriteFailed
        }
    }

    private func pathComponent(for kind: PetMediaKind, fileExtension: String) -> String {
        switch kind {
        case .avatar(let profileID):
            return "\(profileID)-avatar.\(fileExtension)"
        case .post(let petID, let postID):
            return "\(petID)-\(postID).\(fileExtension)"
        }
    }
}
