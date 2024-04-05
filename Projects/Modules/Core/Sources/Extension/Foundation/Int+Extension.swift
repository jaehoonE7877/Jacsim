//
//  Int+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

extension Int {
    /**
     3자리마다 콤마를 추가한 문자열로 변환합니다.
     Tag: #콤마, #.
     */
    public var withComma: String {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = NumberFormatter.Style.decimal
        decimalFormatter.groupingSeparator = ","
        decimalFormatter.groupingSize = 3
        return decimalFormatter.string(from: self as NSNumber)!
    }
    
    /**
     정수를 문자열로 변환합니다.
     
     - Returns: 정수를 문자열로 변환한 값
     Tag: #IntToString
     */
    public func toString() -> String {
            "\(self)"
    }
}
