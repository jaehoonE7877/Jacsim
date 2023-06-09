//
//  UIView+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2023/06/09.
//

import UIKit

extension UIView {
    /**
     여러 개의 뷰를 현재 뷰에 추가합니다.
     
     - Parameter views: 추가할 뷰들의 배열.
     */
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}
