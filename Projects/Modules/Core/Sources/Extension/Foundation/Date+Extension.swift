//
//  Date+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

public enum DateFormat: String {
    ///yyyy-MM-dd hh:mm:ss
    case defaultFormat = "yyyy-MM-dd hh:mm:ss"
    ///yyyy-MM-dd HH:mm:ss
    case default24Format = "yyyy-MM-dd HH:mm:ss"
    ///yyyy년 M월 d일 EEEE
    case full = "yyyy년 M월 d일 EEEE"
    ///yyyy년 M월 d일 EEEE a hh:mm
    case fullWithTime = "yyyy년 M월 d일 EEEE a hh:mm"
    ///yyyyMMddHHmmss
    case YYYYMMDDHHmmss = "yyyyMMddHHmmss"
    ///MM월 dd일 EEEE
    case MMddEEEE = "MM월 dd일 EEEE"
    ///a hh:mm
    case ahhmm = "a hh:mm"
}

public extension Date {}

public extension Date {
    
    var calendar: Calendar { Calendar.current }
    
    /// 연중 주차.
    ///
    ///        Date().weekOfYear -> 2 // 연중 두 번째 주.
    ///
    var weekOfYear: Int {
        return calendar.component(.weekOfYear, from: self)
    }
    
    /// 월간 주차.
    ///
    ///        Date().weekOfMonth -> 3 // 이번 달 세 번째 주.
    ///
    var weekOfMonth: Int {
        return calendar.component(.weekOfMonth, from: self)
    }

    /// 연도.
    ///
    ///        Date().year -> 2017
    ///
    ///        var someDate = Date()
    ///        someDate.year = 2000 // someDate의 연도를 2000으로 변경합니다.
    ///
    var year: Int {
        get {
            return calendar.component(.year, from: self)
        }
        set {
            guard newValue > 0 else { return }
            let currentYear = calendar.component(.year, from: self)
            let yearsToAdd = newValue - currentYear
            if let date = calendar.date(byAdding: .year, value: yearsToAdd, to: self) {
                self = date
            }
        }
    }
    /// 월.
    ///
    ///     Date().month -> 1
    ///
    ///     var someDate = Date()
    ///     someDate.month = 10 // someDate의 월을 10월로 변경합니다.
    ///
    var month: Int {
        get {
            return calendar.component(.month, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .month, in: .year, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentMonth = calendar.component(.month, from: self)
            let monthsToAdd = newValue - currentMonth
            if let date = calendar.date(byAdding: .month, value: monthsToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// 일.
    ///
    ///     Date().day -> 12
    ///
    ///     var someDate = Date()
    ///     someDate.day = 1 // someDate의 일을 1일로 변경합니다.
    ///
    var day: Int {
        get {
            return calendar.component(.day, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .day, in: .month, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentDay = calendar.component(.day, from: self)
            let daysToAdd = newValue - currentDay
            if let date = calendar.date(byAdding: .day, value: daysToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// 요일.
    ///
    ///     Date().weekday -> 5 // 현재 주의 다섯 번째 요일.
    ///
    var weekday: Int {
        return calendar.component(.weekday, from: self)
    }

    /// 시각.
    ///
    ///     Date().hour -> 17 // 오후 5시
    ///
    ///     var someDate = Date()
    ///     someDate.hour = 13 // someDate의 시간을 오후 1시(13시)로 변경합니다.
    ///
    var hour: Int {
        get {
            return calendar.component(.hour, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .hour, in: .day, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentHour = calendar.component(.hour, from: self)
            let hoursToAdd = newValue - currentHour
            if let date = calendar.date(byAdding: .hour, value: hoursToAdd, to: self) {
                self = date
            }
        }
    }

    /// 분.
    ///
    ///     Date().minute -> 39
    ///
    ///     var someDate = Date()
    ///     someDate.minute = 10 // someDate의 분을 10으로 변경합니다.
    ///
    var minute: Int {
        get {
            return calendar.component(.minute, from: self)
        }
        set {
            let allowedRange = calendar.range(of: .minute, in: .hour, for: self)!
            guard allowedRange.contains(newValue) else { return }

            let currentMinutes = calendar.component(.minute, from: self)
            let minutesToAdd = newValue - currentMinutes
            if let date = calendar.date(byAdding: .minute, value: minutesToAdd, to: self) {
                self = date
            }
        }
    }
    
    /// 미래 시각인지 확인합니다.
    ///
    ///     Date(timeInterval: 100, since: Date()).isInFuture -> true
    ///
    var isInFuture: Bool {
        return self > Date()
    }
    
    /// 과거 시각인지 확인합니다.
    ///
    ///     Date(timeInterval: -100, since: Date()).isInPast -> true
    ///
    var isInPast: Bool {
        return self < Date()
    }
    
    /// 오늘 범위인지 확인합니다.
    ///
    ///     Date().isInToday -> true
    ///
    var isInToday: Bool {
        return calendar.isDateInToday(self)
    }
    
    /// 어제 범위인지 확인합니다.
    ///
    ///     Date().isInYesterday -> false
    ///
    var isInYesterday: Bool {
        return calendar.isDateInYesterday(self)
    }
    
    /// 어제 날짜.
    ///
    ///     let date = Date() // "2018년 10월 3일, 10:57:11"
    ///     let yesterday = date.yesterday // "2018년 10월 2일 10:57:11"
    ///
    var yesterday: Date {
        return calendar.date(byAdding: .day, value: -1, to: self) ?? Date()
    }
    
    /// 내일 날짜.
    ///
    ///     let date = Date() // "2018년 10월 3일, 10:57:11"
    ///     let tomorrow = date.tomorrow // "2018년 10월 4일 10:57:11"
    ///
    var tomorrow: Date {
        return calendar.date(byAdding: .day, value: 1, to: self) ?? Date()
    }
    
    /// 두 날짜 사이에 있는지 확인합니다.
    ///
    /// - Parameters:
    ///   - startDate: 비교 기준 시작 날짜입니다.
    ///   - endDate: 비교 기준 종료 날짜입니다.
    ///   - includeBounds: 시작/종료 날짜를 포함할지 여부를 지정합니다. 기본값은 false입니다.
    /// - Returns: 두 날짜 사이에 위치하면 true를 반환합니다.
    func isBetween(_ startDate: Date, _ endDate: Date, includeBounds: Bool = false) -> Bool {
        if includeBounds {
            return startDate.compare(self).rawValue * compare(endDate).rawValue >= 0
        }
        return startDate.compare(self).rawValue * compare(endDate).rawValue > 0
    }
    
    func daysBetween(_ date: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = .KR
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: self), to: calendar.startOfDay(for: date))
        return components.day ?? 0
    }
}

public extension TimeZone {
    static var KR: TimeZone {
        return TimeZone(abbreviation: "KST")!
    }
}

public extension Locale {
    /// 태그: #KR
    static var KR: Locale {
        return Locale(identifier: "ko_kr")
    }
}
