import Foundation

public struct ImageStorePort: Sendable {
    public var saveImage: @Sendable (_ key: String, _ data: Data) async throws -> String
    public var loadImage: @Sendable (_ key: String) async -> Data?
    public var deleteImage: @Sendable (_ key: String) async -> Void
    public var imageExists: @Sendable (_ key: String) async -> Bool

    public init(
        saveImage: @escaping @Sendable (_ key: String, _ data: Data) async throws -> String,
        loadImage: @escaping @Sendable (_ key: String) async -> Data?,
        deleteImage: @escaping @Sendable (_ key: String) async -> Void,
        imageExists: @escaping @Sendable (_ key: String) async -> Bool
    ) {
        self.saveImage = saveImage
        self.loadImage = loadImage
        self.deleteImage = deleteImage
        self.imageExists = imageExists
    }
}
