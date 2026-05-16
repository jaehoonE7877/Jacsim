import UIKit

enum ImageStoreInputEncodingError: Error {
    case jpegEncodingFailed
}

func makeImageStoreInputData(
    from image: UIImage,
    compressionQuality: CGFloat = 0.95
) throws -> Data {
    guard let data = image.jpegData(compressionQuality: compressionQuality) else {
        throw ImageStoreInputEncodingError.jpegEncodingFailed
    }
    return data
}
