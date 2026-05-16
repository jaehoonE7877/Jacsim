import Foundation
import ExternalInterface
import UIKit

public actor DocumentImageStoreAdapter {
    private let fileManager: FileManager
    private let imageDirectory: URL?
    private let maxPixelDimension: CGFloat
    private let compressionQuality: CGFloat
    
    public init(
        fileManager: FileManager = .default,
        imageDirectory: URL? = nil,
        maxPixelDimension: CGFloat = 1_600,
        compressionQuality: CGFloat = 0.72
    ) {
        self.fileManager = fileManager
        self.imageDirectory = imageDirectory ?? fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Image")
        self.maxPixelDimension = maxPixelDimension
        self.compressionQuality = compressionQuality
    }
    
    public func saveImage(key: String, data: Data) async throws -> String {
        try createImageDirectoryIfNeeded()
        
        let fileURL = try fileURL(for: key)
        let storageData = try makeStorageData(from: data)
        try storageData.write(to: fileURL, options: [.atomic])
        try? fileManager.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: fileURL.path
        )
        return key
    }
    
    public func loadImage(key: String) async -> Data? {
        guard let fileURL = try? fileURL(for: key) else { return nil }
        return try? Data(contentsOf: fileURL)
    }
    
    public func deleteImage(key: String) async {
        guard let fileURL = try? fileURL(for: key) else { return }
        try? fileManager.removeItem(at: fileURL)
    }
    
    public func imageExists(key: String) async -> Bool {
        guard let fileURL = try? fileURL(for: key) else { return false }
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    private func createImageDirectoryIfNeeded() throws {
        guard let imageDirectory else {
            throw ImageStoreError.directoryNotFound
        }
        if !fileManager.fileExists(atPath: imageDirectory.path) {
            try fileManager.createDirectory(
                at: imageDirectory,
                withIntermediateDirectories: true,
                attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
            )
        }
    }

    private func fileURL(for key: String) throws -> URL {
        guard let imageDirectory else {
            throw ImageStoreError.directoryNotFound
        }

        let fileName = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !fileName.isEmpty,
              fileName == (fileName as NSString).lastPathComponent,
              !fileName.contains("..") else {
            throw ImageStoreError.invalidKey
        }

        return imageDirectory.appendingPathComponent(fileName, isDirectory: false)
    }

    private func makeStorageData(from data: Data) throws -> Data {
        guard let image = UIImage(data: data) else {
            throw ImageStoreError.invalidImage
        }

        let storageImage = image.resizedForStorage(maxPixelDimension: maxPixelDimension)
        guard let storageData = storageImage.jpegData(compressionQuality: compressionQuality) else {
            throw ImageStoreError.invalidImage
        }
        return storageData
    }
}

public enum ImageStoreError: Error {
    case adapterDeallocated
    case directoryNotFound
    case invalidKey
    case invalidImage
    case writeFailed(Error)
    case readFailed(Error)
}

private extension UIImage {
    func resizedForStorage(maxPixelDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxPixelDimension, longestSide > 0 else {
            return normalizedForStorage()
        }

        let scale = maxPixelDimension / longestSide
        let targetSize = CGSize(
            width: max(1, floor(size.width * scale)),
            height: max(1, floor(size.height * scale))
        )
        return renderedForStorage(size: targetSize)
    }

    func normalizedForStorage() -> UIImage {
        renderedForStorage(size: size)
    }

    func renderedForStorage(size targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
