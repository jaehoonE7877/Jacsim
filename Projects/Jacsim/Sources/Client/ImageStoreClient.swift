import ComposableArchitecture
import ExternalInterface
import Data

private enum ImageStoreKey: DependencyKey {
    static let liveValue: ImageStorePort = {
        let adapter = DocumentImageStoreAdapter()
        return ImageStorePort(
            saveImage: { try await adapter.saveImage(key: $0, data: $1) },
            loadImage: { await adapter.loadImage(key: $0) },
            deleteImage: { await adapter.deleteImage(key: $0) },
            imageExists: { await adapter.imageExists(key: $0) }
        )
    }()
    
    static let testValue = ImageStorePort(
        saveImage: { _, _ in "" },
        loadImage: { _ in nil },
        deleteImage: { _ in },
        imageExists: { _ in false }
    )
}

extension DependencyValues {
    var imageStore: ImageStorePort {
        get { self[ImageStoreKey.self] }
        set { self[ImageStoreKey.self] = newValue }
    }
}
