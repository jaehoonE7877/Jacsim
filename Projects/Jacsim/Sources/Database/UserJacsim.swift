//
//  RealmModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import RealmSwift
import UIKit

class UserJacsim: Object {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var title: String
    @Persisted var startDate: Date
    @Persisted var endDate: Date
    @Persisted var isDone: Bool
    @Persisted var success: Int
    @Persisted var isSuccess: Bool
    @Persisted var alarm: Date?

    @Persisted var memoList: List<Certified>

    convenience init(title: String, startDate: Date, endDate: Date, isDone: Bool = false, success: Int, isSuccess: Bool = false, alarm: Date?){
        self.init()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isDone = isDone
        self.success = success
        self.isSuccess = isSuccess
        self.alarm = alarm
    }
    
    override class func primaryKey() -> String? {
        return "id"
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
        if DateFormatType.toString(Date(), to: .fullWithoutYear) == dateText {
            return true
        } else {
            return false
        }
    }
    
    var mainImageURL: String {
        return "\(id).jpg"
    }
    
    var certifiedImageURL: [String] {
        let dateTextArray = jacsimDayArray.map { DateFormatType.toString($0, to: .fullWithoutYear)}
        let imageURLArray = dateTextArray.map { "\(id)_\($0).jpg" }
        return imageURLArray
    }
}

class Certified: Object {
   
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var memo: String
    @Persisted var check: Bool
    
    let forUserjacsim = LinkingObjects(fromType: UserJacsim.self, property: "memo")
    
    convenience init(memo: String) {
        self.init()
        self.memo = memo
        self.check = false
    }
}
