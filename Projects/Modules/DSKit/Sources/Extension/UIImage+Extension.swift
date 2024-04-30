//
//  UIImage+Extension.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 5/1/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

import Core

public extension UIImage {
    /**
     Tag: #imageResize, #Reisze
     */
    func resizeImage(_ dimension: CGFloat, opaque: Bool,
                     contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = opaque
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
        newImage = renderer.image {
            (context) in
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        return newImage
    }
}

public extension UIImage {
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInKB: Int) -> Data? {
        let sizeInBytes = expectedSizeInKB * 1024
        var needCompress: Bool = true
        var imgData: Data?
        var compressingValue: CGFloat = 1.0
        var count = 9
        while (needCompress && compressingValue > 0.0) {
            if let data: Data = self.jpegData(compressionQuality: compressingValue) {
                Log(sizeInBytes)
                Log(compressingValue)
                Log("sizeInbyte \(sizeInBytes) data.count \(data.count)")
                if count == 0 {
                    return data
                }
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                    count -= 1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return data
            }
        }
        return self.jpegData(compressionQuality: 1)
    }
}
