import Foundation
import SwiftUI
import PhotosUI
import UIKit

enum PhotoPickerImageLoader {
    static func loadImage(from item: PhotosPickerItem?) async -> UIImage? {
        guard let item else { return nil }
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return nil
        }
        return UIImage(data: data)
    }
}
