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

    var startDateStringFull: String { DateFormatType.toString(startDate, to: .full) }
    var endDateStringFull: String { DateFormatType.toString(endDate, to: .full) }
    var alarmString: String { alarm.map { DateFormatType.toString($0, to: .time) } ?? "설정된 알람이 없습니다." }
    var imageBaseName: String { id.uuidString }

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
}

@Model
final class Certified {
    var id: UUID
    var memo: String
    var check: Bool

    init(id: UUID = UUID(), memo: String, check: Bool = false) {
        self.id = id
        self.memo = memo
        self.check = check
    }
}

