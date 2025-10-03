//
//  UISwitch+Extension.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

public extension UISwitch {
    var isOff: Bool {
        !self.isOn
    }
}
