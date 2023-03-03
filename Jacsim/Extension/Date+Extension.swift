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
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
}

extension Date {
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
}

