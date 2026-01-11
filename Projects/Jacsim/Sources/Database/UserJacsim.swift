//
//  UserJacsim.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import Foundation
import SwiftData

@Model
public final class UserJacsim {

    @Attribute(.unique) public var id: UUID

    public var title: String
    public var startDate: Date
    public var endDate: Date
    public var isDone: Bool
    public var success: Int
    public var isSuccess: Bool
    public var alarm: Date?
    public var statusRaw: String = ChallengeStatus.inProgress.rawValue
    public var resultRaw: String = ChallengeResult.none.rawValue
    public var currentStageTypeRaw: Int = StageType.three.rawValue
    public var isNotificationEnabled: Bool = false

    @Relationship(deleteRule: .cascade)
    public var memoList: [Certified]

    @Relationship(deleteRule: .cascade)
    public var stages: [Stage]

    public init(id: UUID = UUID(),
         title: String,
         startDate: Date,
         endDate: Date,
         isDone: Bool = false,
         success: Int,
         isSuccess: Bool = false,
         alarm: Date? = nil,
         statusRaw: String = ChallengeStatus.inProgress.rawValue,
         resultRaw: String = ChallengeResult.none.rawValue,
         currentStageTypeRaw: Int = StageType.three.rawValue,
         isNotificationEnabled: Bool = false,
         memoList: [Certified] = [],
         stages: [Stage] = []) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isDone = isDone
        self.success = success
        self.isSuccess = isSuccess
        self.alarm = alarm
        self.statusRaw = statusRaw
        self.resultRaw = resultRaw
        self.currentStageTypeRaw = currentStageTypeRaw
        self.isNotificationEnabled = isNotificationEnabled || alarm != nil
        self.memoList = memoList
        self.stages = stages
    }

    public var status: ChallengeStatus {
        get { ChallengeStatus(rawValue: statusRaw) ?? .inProgress }
        set { statusRaw = newValue.rawValue }
    }

    public var result: ChallengeResult {
        get { ChallengeResult(rawValue: resultRaw) ?? .none }
        set { resultRaw = newValue.rawValue }
    }

    public var currentStageType: StageType {
        get { StageType(rawValue: currentStageTypeRaw) ?? .three }
        set { currentStageTypeRaw = newValue.rawValue }
    }

    public var startDateStringFull: String {
        DateFormatType.toString(startDate, to: .full)
    }

    public var endDateStringFull: String {
        DateFormatType.toString(endDate, to: .full)
    }

    public var alarmString: String {
        if let alarm = alarm {
            return DateFormatType.toString(alarm, to: .time)
        } else {
            return "설정된 알람이 없습니다."
        }
    }

    public var jacsimDayArray: [Date] {
        var dayArray: [Date] = []
        for date in stride(from: startDate, to: endDate + 86400, by: 86400) {
            dayArray.append(date)
        }
        return dayArray
    }

    public func checkIsToday(indexPath: Int) -> Bool {
        let dateText = DateFormatType.toString(jacsimDayArray[indexPath], to: .fullWithoutYear)
        return DateFormatType.toString(Date(), to: .fullWithoutYear) == dateText
    }

    public var mainImageURL: String {
        return "\(id).jpg"
    }

    public var certifiedImageURL: [String] {
        let dateTextArray = jacsimDayArray.map { DateFormatType.toString($0, to: .fullWithoutYear) }
        let imageURLArray = dateTextArray.map { "\(id)_\($0).jpg" }
        return imageURLArray
    }
}

@Model
public final class Certified {

    @Attribute(.unique) public var id: UUID

    public var memo: String
    public var check: Bool
    public var date: Date = Date()
    public var imagePath: String?

    @Relationship(inverse: \UserJacsim.memoList)
    public var userJacsim: UserJacsim?

    @Relationship(inverse: \Stage.dailyRecords)
    public var stage: Stage?

    public init(id: UUID = UUID(),
         memo: String,
         check: Bool = false,
         date: Date = Date(),
         imagePath: String? = nil,
         userJacsim: UserJacsim? = nil,
         stage: Stage? = nil) {
        self.id = id
        self.memo = memo
        self.check = check
        self.date = date
        self.imagePath = imagePath
        self.userJacsim = userJacsim
        self.stage = stage
    }
}

extension UserJacsim: @unchecked Sendable {}
extension Certified: @unchecked Sendable {}
