//
//  UIImageView+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/14.
//

import Foundation
import UIKit

extension UIImage {
    
    func getCustomImage(imageName: String, size: CGFloat) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: size)
        return UIImage(systemName: imageName, withConfiguration: config)
    }
    
}
