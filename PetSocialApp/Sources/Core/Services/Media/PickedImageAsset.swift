import Foundation
import UniformTypeIdentifiers

struct PickedImageAsset: Equatable, Sendable {
    let data: Data
    let mimeType: String
    let fileExtension: String

    init(data: Data, contentType: UTType?) {
        self.data = data

        if let mimeType = contentType?.preferredMIMEType {
            self.mimeType = mimeType
        } else {
            self.mimeType = "image/jpeg"
        }

        if let preferredExtension = contentType?.preferredFilenameExtension {
            self.fileExtension = preferredExtension
        } else {
            self.fileExtension = "jpg"
        }
    }
}
