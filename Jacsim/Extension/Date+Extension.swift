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
    
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        formatter.timeZone = TimeZone(identifier: "UTC+9")
        return formatter.string(from: self)
    }
    
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
        formatter.timeZone = TimeZone(identifier: "UTC+9")
        if let date = formatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}
