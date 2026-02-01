import Foundation
import ExternalInterface

public actor DocumentImageStoreAdapter {
    private let fileManager: FileManager
    private let imageDirectory: URL?
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.imageDirectory = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Image")
    }
    
    public func saveImage(key: String, data: Data) async throws -> String {
        createImageDirectoryIfNeeded()
        
        guard let imageDirectory else {
            throw ImageStoreError.directoryNotFound
        }
        
        let fileURL = imageDirectory.appendingPathComponent(key)
        try data.write(to: fileURL)
        return key
    }
    
    public func loadImage(key: String) async -> Data? {
        guard let imageDirectory else { return nil }
        let fileURL = imageDirectory.appendingPathComponent(key)
        return try? Data(contentsOf: fileURL)
    }
    
    public func deleteImage(key: String) async {
        guard let imageDirectory else { return }
        let fileURL = imageDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    public func imageExists(key: String) async -> Bool {
        guard let imageDirectory else { return false }
        let fileURL = imageDirectory.appendingPathComponent(key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    private func createImageDirectoryIfNeeded() {
        guard let imageDirectory else { return }
        if !fileManager.fileExists(atPath: imageDirectory.path) {
            try? fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        }
    }
}

public enum ImageStoreError: Error {
    case adapterDeallocated
    case directoryNotFound
    case writeFailed(Error)
    case readFailed(Error)
}
