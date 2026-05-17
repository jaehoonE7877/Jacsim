import Data
import Foundation
import SwiftData
import DSKit

struct WidgetTask: Identifiable, Hashable {
    let id: UUID
    let title: String
    let dDay: Int
    let currentDays: Int
    let targetDays: Int
    let stageType: JSStageRing.StageType

    var url: URL {
        URL(string: "jacsim://task/\(id.uuidString)")!
    }
}

enum WidgetDataProvider {
    static func fetchActiveTasks(limit: Int = 3) -> [WidgetTask] {
        do {
            let context = try makeContext()
            let descriptor = FetchDescriptor<UserJacsimModel>(
                sortBy: [SortDescriptor(\.endDate, order: .forward)]
            )
            return try context.fetch(descriptor)
                .filter { !$0.isDone && $0.statusRaw == "inProgress" }
                .prefix(limit)
                .map(mapTask)
        } catch {
            return []
        }
    }

    static func fetchStreakStates(endDate: Date = Date()) -> [Date: StreakState] {
        do {
            let context = try makeContext()
            let calendar = Calendar.current
            let endDay = calendar.startOfDay(for: endDate)
            let startDay = calendar.date(byAdding: .day, value: -83, to: endDay) ?? endDay
            let descriptor = FetchDescriptor<CertifiedModel>(
                predicate: #Predicate { record in
                    record.date >= startDay && record.date <= endDay
                },
                sortBy: [SortDescriptor(\.date, order: .forward)]
            )
            return Dictionary(uniqueKeysWithValues: try context.fetch(descriptor).map {
                (calendar.startOfDay(for: $0.date), $0.check ? StreakState.completed : StreakState.empty)
            })
        } catch {
            return [:]
        }
    }

    private static func makeContext() throws -> ModelContext {
        ModelContext(try SwiftDataStack.makeContainer())
    }

    private static func mapTask(_ model: UserJacsimModel) -> WidgetTask {
        let stage = model.stages.sorted { $0.startDate < $1.startDate }.last
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let endDate = calendar.startOfDay(for: model.endDate)
        let dDay = max(0, calendar.dateComponents([.day], from: today, to: endDate).day ?? 0)
        return WidgetTask(
            id: model.id,
            title: model.title,
            dDay: dDay,
            currentDays: stage?.successDays ?? model.success,
            targetDays: max(1, stage?.durationDays ?? max(1, model.memoList.count)),
            stageType: JSStageRing.StageType(rawValue: stage?.stageTypeRaw ?? model.currentStageTypeRaw ?? 3) ?? .three
        )
    }
}
