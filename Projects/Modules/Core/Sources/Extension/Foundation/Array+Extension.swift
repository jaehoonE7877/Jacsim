//
//  Array+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

public extension Array {
    /**
     배열이 비어있지 않은지 여부를 나타내는 불리언 값입니다.
     Tag: #Array, #Empty
     */
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    /**
     안전한 인덱스를 사용하여 요소에 접근합니다.
     
     - Parameter safeIndex: 안전한 인덱스.
     - Returns: 인덱스에 해당하는 요소 또는 nil (인덱스가 유효하지 않은 경우).
     Tag: #index, #SafeIndex
     */
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
