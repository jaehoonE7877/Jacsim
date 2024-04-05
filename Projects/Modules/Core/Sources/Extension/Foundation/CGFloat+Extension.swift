//
//  CGFloat+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

extension CGFloat {
    /**
     화면의 가로 너비를 나타내는 CGFloat 값입니다.
     Tag: #화면, #가로, #width, #넓이
     */
    public static var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    /**
     화면의 세로 높이를 나타내는 CGFloat 값입니다.
     Tag: #화면, #세로, #height, #높이
     */
    public static var screenHeight: CGFloat = UIScreen.main.bounds.height
}
