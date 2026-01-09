//
//  UserJacsim.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import Foundation
import SwiftData

@Model
final class UserJacsim {

    @Attribute(.unique) var id: UUID

    var title: String
    var startDate: Date
    var endDate: Date
    var isDone: Bool
    var success: Int
    var isSuccess: Bool
    var alarm: Date?

    @Relationship(deleteRule: .cascade)
    var memoList: [Certified]

    init(id: UUID = UUID(),
         title: String,
         startDate: Date,
         endDate: Date,
         isDone: Bool = false,
         success: Int,
         isSuccess: Bool = false,
         alarm: Date? = nil,
         memoList: [Certified] = []) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isDone = isDone
        self.success = success
        self.isSuccess = isSuccess
        self.alarm = alarm
        self.memoList = memoList
    }

    var startDateStringFull: String {
        DateFormatType.toString(startDate, to: .full)
    }

    var endDateStringFull: String {
        DateFormatType.toString(endDate, to: .full)
    }

    var alarmString: String {
        if let alarm = alarm {
            return DateFormatType.toString(alarm, to: .time)
        } else {
            return "설정된 알람이 없습니다."
        }
    }

    var jacsimDayArray: [Date] {
        var dayArray: [Date] = []
        for date in stride(from: startDate, to: endDate + 86400, by: 86400) {
            dayArray.append(date)
        }
        return dayArray
    }

    func checkIsToday(indexPath: Int) -> Bool {
        let dateText = DateFormatType.toString(jacsimDayArray[indexPath], to: .fullWithoutYear)
        return DateFormatType.toString(Date(), to: .fullWithoutYear) == dateText
    }

    var mainImageURL: String {
        return "\(id).jpg"
    }

    var certifiedImageURL: [String] {
        let dateTextArray = jacsimDayArray.map { DateFormatType.toString($0, to: .fullWithoutYear) }
        let imageURLArray = dateTextArray.map { "\(id)_\($0).jpg" }
        return imageURLArray
    }
}

@Model
final class Certified {

    @Attribute(.unique) var id: UUID

    var memo: String
    var check: Bool

    @Relationship(inverse: \UserJacsim.memoList)
    var userJacsim: UserJacsim?

    init(id: UUID = UUID(),
         memo: String,
         check: Bool = false,
         userJacsim: UserJacsim? = nil) {
        self.id = id
        self.memo = memo
        self.check = check
        self.userJacsim = userJacsim
    }
}
