//
//  Date+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/19.
//

import Foundation

extension Date : Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate + 86400
    }
    
    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}
