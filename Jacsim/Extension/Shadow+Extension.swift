//
//  Shadow+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/14.
//

import UIKit

extension UIView {
    
    static func makeShadow<T: UIView>(view: T){
        view.layer.cornerRadius = 8
        
        view.layer.borderWidth = 0
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 4, height: 4)
        view.layer.shadowOpacity = 0.8
        view.layer.cornerRadius = Constant.Design.cornerRadius
    }
    
}
