import Foundation

public enum ChallengeDetailState: Sendable, Equatable {
    case stagePending
    case stageSuccess
    case stageFail
    case habitCompleted
    
    public var isStagePending: Bool {
        self == .stagePending
    }
    
    public var isStageSuccess: Bool {
        self == .stageSuccess
    }
    
    public var isStageFail: Bool {
        self == .stageFail
    }
    
    public var isHabitCompleted: Bool {
        self == .habitCompleted
    }
}

public enum TodayStatus: Sendable, Equatable {
    case notCertified
    case certified
    
    public var title: String {
        switch self {
        case .notCertified:
            return "오늘 미인증"
        case .certified:
            return "오늘 인증 완료"
        }
    }
}

public struct DayViewData: Sendable, Equatable, Identifiable {
    public var id: Date { date }
    public let date: Date
    public let memo: String
    public let isChecked: Bool
    
    public init(date: Date, memo: String, isChecked: Bool) {
        self.date = date
        self.memo = memo
        self.isChecked = isChecked
    }
}

public struct ChallengeStateEvaluation: Sendable, Equatable {
    public let challengeState: ChallengeDetailState
    public let todayStatus: TodayStatus
    public let currentStage: StageSnapshot?
    public let stageProgress: Double
    public let stageProgressText: String
    public let remainingSuccessCount: Int
    public let todayMemo: String
    public let dayViewData: [DayViewData]
    
    public init(
        challengeState: ChallengeDetailState,
        todayStatus: TodayStatus,
        currentStage: StageSnapshot?,
        stageProgress: Double,
        stageProgressText: String,
        remainingSuccessCount: Int,
        todayMemo: String,
        dayViewData: [DayViewData]
    ) {
        self.challengeState = challengeState
        self.todayStatus = todayStatus
        self.currentStage = currentStage
        self.stageProgress = stageProgress
        self.stageProgressText = stageProgressText
        self.remainingSuccessCount = remainingSuccessCount
        self.todayMemo = todayMemo
        self.dayViewData = dayViewData
    }
}

public struct ChallengeStateService: Sendable {
    public init() {}
    
    public func evaluateChallengeState(for task: Task, today: Date) -> ChallengeStateEvaluation {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        
        let currentStage = task.stages.last
        
        let remainingSuccessCount = max(0, (currentStage?.durationDays ?? 0) - task.records.filter(\.check).count)
        
        let isTodayInRange = todayStart >= calendar.startOfDay(for: task.startDate)
            && todayStart <= calendar.startOfDay(for: task.endDate)
        
        let todayStatus: TodayStatus
        let todayMemo: String
        if isTodayInRange {
            let todayRecord = task.records.first { calendar.isDate($0.date, inSameDayAs: todayStart) }
            todayStatus = (todayRecord?.check == true) ? .certified : .notCertified
            todayMemo = todayRecord?.memo ?? ""
        } else {
            todayStatus = .notCertified
            todayMemo = ""
        }
        
        let challengeState: ChallengeDetailState
        let stageProgress: Double
        let stageProgressText: String
        
        if let stage = currentStage {
            let stageResult = stage.result
            let isFinalStage = stage.stageType == .thirty
            
            switch stageResult {
            case .inProgress:
                challengeState = .stagePending
            case .success:
                challengeState = isFinalStage ? .habitCompleted : .stageSuccess
            case .fail:
                challengeState = .stageFail
            }
            
            let stageStart = stage.startDate
            let stageEnd = stage.endDate
            let totalStageDays = stage.durationDays
            
            let stageRecords = task.records.filter { record in
                let recordDate = calendar.startOfDay(for: record.date)
                return recordDate >= calendar.startOfDay(for: stageStart)
                    && recordDate <= calendar.startOfDay(for: stageEnd)
            }
            let successCount = stageRecords.filter(\.check).count
            
            stageProgress = totalStageDays > 0 ? Double(successCount) / Double(totalStageDays) : 0
            stageProgressText = "\(successCount)/\(totalStageDays)"
        } else {
            challengeState = .stagePending
            stageProgress = 0
            stageProgressText = "0/7"
        }
        
        let dates = task.dayArray.reversed()
        let dayViewData: [DayViewData] = dates.enumerated().map { index, date in
            let originalIndex = task.dayArray.count - 1 - index
            let memo = task.records.indices.contains(originalIndex) ? task.records[originalIndex].memo : "인증해주세요"
            let isChecked = task.records.indices.contains(originalIndex) ? task.records[originalIndex].check : false
            return DayViewData(date: date, memo: memo, isChecked: isChecked)
        }
        
        return ChallengeStateEvaluation(
            challengeState: challengeState,
            todayStatus: todayStatus,
            currentStage: currentStage,
            stageProgress: stageProgress,
            stageProgressText: stageProgressText,
            remainingSuccessCount: remainingSuccessCount,
            todayMemo: todayMemo,
            dayViewData: dayViewData
        )
    }
}
