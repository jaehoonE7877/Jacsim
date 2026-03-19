import ComposableArchitecture
import Ports

private enum ImageStoreKey: DependencyKey {
    static let liveValue: ImageStorePort = DependencyAssembly.imageStore
    
    static let testValue = ImageStorePort(
        saveImage: { _, _ in "" },
        loadImage: { _ in nil },
        deleteImage: { _ in },
        imageExists: { _ in false }
    )
}

public extension DependencyValues {
    var imageStore: ImageStorePort {
        get { self[ImageStoreKey.self] }
        set { self[ImageStoreKey.self] = newValue }
    }
}
