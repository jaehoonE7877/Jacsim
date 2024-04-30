//
//  ImageSource.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/8/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//
import UIKit

public enum ImageSource: CaseIterable {
    case camera
    case album
    
    public var title: String {
        switch self {
        case .camera: return "카메라"
        case .album: return "앨범"
        }
    }
    
    public var thumbnail: UIImage {
        switch self {
        case .camera:
            return DSKitAsset.Assets.camera.image.withTintColor(.labelNormal)
        case .album:
            return DSKitAsset.Assets.gallery.image.withTintColor(.labelNormal)
        }
    }
}
