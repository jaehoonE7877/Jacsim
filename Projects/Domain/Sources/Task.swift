import Foundation

public struct TaskID: Sendable, Codable, Hashable {
    public let rawValue: UUID

    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }
}

public struct Task: Sendable, Codable, Hashable, Identifiable {
    public let id: TaskID
    public var title: String
    public var startDate: Date
    public var endDate: Date
    public var stages: [StageSnapshot]
    public var records: [DailyRecordSnapshot]
    public var isDeleted: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: TaskID,
        title: String,
        startDate: Date,
        endDate: Date,
        stages: [StageSnapshot] = [],
        records: [DailyRecordSnapshot] = [],
        isDeleted: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.stages = stages
        self.records = records
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var dayArray: [Date] {
        var days: [Date] = []
        var current = startDate
        while current <= endDate {
            days.append(current)
            current = Calendar.current.date(byAdding: .day, value: 1, to: current) ?? current.addingTimeInterval(86400)
        }
        return days
    }

    public var mainImageKey: String {
        "\(id.rawValue).jpg"
    }

    public func imageKey(for dayIndex: Int) -> String? {
        guard dayArray.indices.contains(dayIndex) else { return nil }
        let date = dayArray[dayIndex]
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일"
        let dateString = formatter.string(from: date)
        return "\(id.rawValue)_\(dateString).jpg"
    }

    public func isToday(dayIndex: Int) -> Bool {
        guard dayArray.indices.contains(dayIndex) else { return false }
        return Calendar.current.isDate(dayArray[dayIndex], inSameDayAs: Date())
    }

    public var currentStage: StageSnapshot? {
        stages.first { $0.result == .inProgress }
    }

    public var successCount: Int {
        records.filter(\.check).count
    }

    public func hasRecord(for date: Date) -> Bool {
        records.contains { record in
            Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }

    public var progress: Double {
        let total = dayArray.count
        guard total > 0 else { return 0 }
        let completed = records.filter { $0.check }.count
        return Double(completed) / Double(total)
    }

    public var completedDays: Int {
        records.filter { $0.check }.count
    }

    public func isCompleted(on date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return records.first { record in
            calendar.isDate(record.date, inSameDayAs: startOfDay)
        }?.check ?? false
    }
}

public struct StageSnapshot: Sendable, Codable, Hashable, Identifiable {
    public let id: UUID
    public var stageTypeRaw: Int
    public var startDate: Date
    public var endDate: Date
    public var durationDays: Int
    public var successDays: Int
    public var resultRaw: String

    public init(
        id: UUID,
        stageTypeRaw: Int,
        startDate: Date,
        endDate: Date,
        durationDays: Int,
        successDays: Int,
        resultRaw: String
    ) {
        self.id = id
        self.stageTypeRaw = stageTypeRaw
        self.startDate = startDate
        self.endDate = endDate
        self.durationDays = durationDays
        self.successDays = successDays
        self.resultRaw = resultRaw
    }

    public var stageType: StageType {
        get { StageType(rawValue: stageTypeRaw) ?? .three }
        set { stageTypeRaw = newValue.rawValue }
    }

    public var result: StageResult {
        get { StageResult(rawValue: resultRaw) ?? .inProgress }
        set { resultRaw = newValue.rawValue }
    }

    public var dayArray: [Date] {
        var days: [Date] = []
        var current = startDate
        while current <= endDate {
            days.append(current)
            current = Calendar.current.date(byAdding: .day, value: 1, to: current) ?? current.addingTimeInterval(86400)
        }
        return days
    }
}

public struct DailyRecordSnapshot: Sendable, Codable, Hashable, Identifiable {
    public let id: UUID
    public var memo: String
    public var check: Bool
    public var date: Date
    public var imagePath: String?

    public init(
        id: UUID,
        memo: String,
        check: Bool,
        date: Date,
        imagePath: String?
    ) {
        self.id = id
        self.memo = memo
        self.check = check
        self.date = date
        self.imagePath = imagePath
    }
}
