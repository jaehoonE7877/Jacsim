import Foundation

public struct CompletionRateResult: Sendable, Codable, Equatable {
    public let totalCount: Int
    public let completedCount: Int
    public let rate: Double?
    
    public init(totalCount: Int, completedCount: Int) {
        self.totalCount = totalCount
        self.completedCount = completedCount
        self.rate = totalCount > 0 ? Double(completedCount) / Double(totalCount) : nil
    }
    
    public var displayText: String {
        guard let rate = rate else { return "데이터 없음" }
        return "\(Int(rate * 100))%"
    }
}

public func calculateCompletionRate(
    for date: Date,
    tasks: [Task]
) -> CompletionRateResult {
    
    let activeTasks = tasks.filter { task in
        task.stages.contains { stage in
            date >= stage.startDate && date <= stage.endDate
        }
    }
    
    let completedCount = activeTasks.filter { task in
        task.hasRecord(for: date)
    }.count
    
    return CompletionRateResult(
        totalCount: activeTasks.count,
        completedCount: completedCount
    )
}
