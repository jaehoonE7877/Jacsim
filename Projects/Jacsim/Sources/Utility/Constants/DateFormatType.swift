//
//  DateFormatType.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/06.
//

import Foundation

enum DateFormatType {
    case full
    case fullWithTime
    case fullWithoutYear
    case time
}

extension DateFormatType {
    
    var format: String {
        switch self {
        case .full:
            return "yyyy년 M월 d일 EEEE"
        case .fullWithTime:
            return "yyyy년 M월 d일 EEEE a hh:mm"
        case .fullWithoutYear:
            return "M월 d일 EEEE"
        case .time:
            return "a hh:mm"
        }
    }
    
    static func toString(_ date: Date, to dateFormat: DateFormatType) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = dateFormat.format
        return dateFormatter.string(from: date)
    }
    
    static func toDate(_ dateString: String, to dateFormat: DateFormatType) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = dateFormat.format
        return dateFormatter.date(from: dateString)
    }
}


