import Foundation

public protocol CreateTaskUseCaseProtocol: Sendable {
    func createTask(
        title: String,
        startDate: Date,
        endDate: Date,
        stageType: StageType
    ) -> Task
}

public struct CreateTaskUseCase: CreateTaskUseCaseProtocol {
    public init() {}
    
    public func createTask(
        title: String,
        startDate: Date,
        endDate: Date,
        stageType: StageType
    ) -> Task {
        let taskId = TaskID(UUID())
        
        let stage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: stageType.rawValue,
            startDate: startDate,
            endDate: endDate,
            durationDays: stageType.durationDays,
            successDays: 0,
            resultRaw: StageResult.inProgress.rawValue
        )
        
        var records: [DailyRecordSnapshot] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let record = DailyRecordSnapshot(
                id: UUID(),
                memo: "",
                check: false,
                date: currentDate,
                imagePath: nil
            )
            records.append(record)
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)
                ?? currentDate.addingTimeInterval(86400)
        }
        
        return Task(
            id: taskId,
            title: title,
            startDate: startDate,
            endDate: endDate,
            stages: [stage],
            records: records,
            isDeleted: false,
            createdAt: .now,
            updatedAt: .now
        )
    }
}
