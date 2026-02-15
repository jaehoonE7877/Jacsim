import Foundation
import Ports

public struct LoadImageUseCase: Sendable {
    public var loadImage: @Sendable (String) async -> Data?

    public init(loadImage: @escaping @Sendable (String) async -> Data?) {
        self.loadImage = loadImage
    }
}

extension LoadImageUseCase {
    public static func live(imageStore: ImageStorePort) -> Self {
        Self(
            loadImage: { key in
                await imageStore.loadImage(key)
            }
        )
    }
}
