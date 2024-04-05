//
//  Bundle+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

extension Bundle {
    /**
      앱의 현재 버전을 나타내는 문자열입니다.
     Tag: #Bundle, #app
      */
     public var appVersion: String? {
         return self.infoDictionary?["CFBundleShortVersionString"] as? String
     }
     
     /**
      메인 번들의 앱 버전을 나타내는 문자열입니다.
      */
     public static var mainAppVersion: String? {
         return Bundle.main.appVersion
     }
}
