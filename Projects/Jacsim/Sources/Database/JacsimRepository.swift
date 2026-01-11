//
//  Repository.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/17.
//

import Foundation
import UserNotifications

import Core

import SwiftData

/*
 레포의 역할 
 */

@MainActor
protocol JacsimRepositoryProtocol: AnyObject {
    func fetchActiveTasks() -> [UserJacsim]
    func fetchIsSuccess() -> [UserJacsim]
    func fetchIsFail() -> [UserJacsim]
    func fetchDate(date: Date) -> [UserJacsim]
    func fetchIsNotDone() -> Int
    func fetchTask(id: UUID) -> UserJacsim?
    func addJacsim(item: UserJacsim)
    func updateMemo(item: UserJacsim, index: Int, memo: String)
    func removeImageFromDocument(fileName: String)
    func deleteJacsim(item: UserJacsim)
    func deleteAlarm(item: UserJacsim)
    func checkIsDone(item: UserJacsim, count: Int)
    func checkIsDone(items: [UserJacsim])
    func checkCertified(item: UserJacsim) -> Int
    func checkIsSuccess(item: UserJacsim)
    func minimumSuccessDays(for durationDays: Int) -> Int
    func evaluateStageResult(_ stage: Stage) -> StageResult
    func createNextStage(for challenge: UserJacsim) -> Stage?
    func updateTaskInfo(task: UserJacsim, title: String, success: Int, isAlarmEnabled: Bool, alarmDate: Date)
    func needsMigrationV0_1() -> Bool
    func performMigrationV0_1()
}

@MainActor
final class JacsimRepository: JacsimRepositoryProtocol {

    static let shared = JacsimRepository()
    private init() {
        let schema = Schema([UserJacsim.self, Certified.self, Stage.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
            context = container.mainContext
        } catch {
            fatalError("SwiftData 컨테이너 초기화 실패: \(error)")
        }
    }

    private let container: ModelContainer
    private let context: ModelContext

    let notificationCenter = UNUserNotificationCenter.current()

    func fetchId(id: UUID) -> [UserJacsim] {
        let descriptor = FetchDescriptor<UserJacsim>(
            predicate: #Predicate { $0.id == id }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchTask(id: UUID) -> UserJacsim? {
        fetchId(id: id).first
    }

    func fetchActiveTasks() -> [UserJacsim] {
        let descriptor = FetchDescriptor<UserJacsim>(
            predicate: #Predicate { $0.isDone == false },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchIsSuccess() -> [UserJacsim] {
        let descriptor = FetchDescriptor<UserJacsim>(
            predicate: #Predicate { $0.isDone == true && $0.isSuccess == true },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchIsFail() -> [UserJacsim] {
        let descriptor = FetchDescriptor<UserJacsim>(
            predicate: #Predicate { $0.isDone == true && $0.isSuccess == false },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func fetchIsNotDone() -> Int {
        let descriptor = FetchDescriptor<UserJacsim>(
            predicate: #Predicate { $0.isDone == false }
        )
        return (try? context.fetch(descriptor).count) ?? 0
    }

    func fetchDate(date: Date) -> [UserJacsim] {
        let endDate = Date(timeInterval: 86400, since: date)
        let descriptor = FetchDescriptor<UserJacsim>(
            predicate: #Predicate { $0.isDone == false && $0.endDate >= date && $0.startDate < endDate },
            sortBy: [SortDescriptor(\.startDate, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func addJacsim(item: UserJacsim) {
        context.insert(item)
        do {
            try context.save()
            scheduleAlarm(for: item)
        } catch {
            print(error)
        }
    }

    func deleteAlarm(item: UserJacsim) {
        removeAlarm(for: item)
        item.alarm = nil
        item.isNotificationEnabled = false
        do {
            try context.save()
        } catch {
            print(error)
        }
    }

    func updateMemo(item: UserJacsim, index: Int, memo: String) {
        guard item.memoList.indices.contains(index) else { return }
        item.memoList[index].memo = memo
        item.memoList[index].check = true
        do {
            try context.save()
        } catch {
            print(error)
        }
    }

    func removeImageFromDocument(fileName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let imageDirectory = documentDirectory.appendingPathComponent("Image")
        let fileURL = imageDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error)
        }
    }

    func deleteJacsim(item: UserJacsim) {
        if item.alarm != nil {
            removeImageFromDocument(fileName: "\(item.id).jpg")
            removeAlarm(for: item)
        } else {
            removeImageFromDocument(fileName: "\(item.id).jpg")
        }

        context.delete(item)
        do {
            try context.save()
        } catch {
            print(error)
        }
    }

    func checkIsDone(item: UserJacsim, count: Int) {
        let certifiedCount = item.memoList.reduce(0) { $0 + ($1.check ? 1 : 0) }
        if certifiedCount == count {
            item.isDone = true
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }

    func checkIsDone(items: [UserJacsim]) {
        var didUpdate = false
        for task in items {
            let end = task.endDate + 86400
            if Date() - end >= 0 {
                task.isDone = true
                didUpdate = true

                if task.alarm != nil {
                    removeAlarm(for: task)
                }
            }
        }

        if didUpdate {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }

    func checkCertified(item: UserJacsim) -> Int {
        item.memoList.reduce(0) { $0 + ($1.check ? 1 : 0) }
    }

    func checkIsSuccess(item: UserJacsim) {
        if checkCertified(item: item) >= item.success {
            item.isSuccess = true
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }

    func minimumSuccessDays(for durationDays: Int) -> Int {
        Int(ceil(Double(durationDays) / 2.0))
    }

    func evaluateStageResult(_ stage: Stage) -> StageResult {
        let evaluatedAt = Calendar.current.date(byAdding: .day, value: 1, to: stage.endDate) ?? stage.endDate.addingTimeInterval(86400)
        if Date() < evaluatedAt {
            return .inProgress
        }
        let isSuccess = stage.successDays >= minimumSuccessDays(for: stage.durationDays)
        return isSuccess ? .success : .fail
    }

    func createNextStage(for challenge: UserJacsim) -> Stage? {
        guard let nextType = challenge.currentStageType.next else { return nil }
        let lastEndDate = challenge.stages.last?.endDate ?? challenge.endDate
        let startDate = Calendar.current.date(byAdding: .day, value: 1, to: lastEndDate) ?? lastEndDate.addingTimeInterval(86400)
        let endDate = Calendar.current.date(byAdding: .day, value: nextType.durationDays - 1, to: startDate)
            ?? startDate.addingTimeInterval(TimeInterval((nextType.durationDays - 1) * 86400))
        let stage = Stage(
            stageTypeRaw: nextType.rawValue,
            startDate: startDate,
            endDate: endDate,
            durationDays: nextType.durationDays
        )
        stage.userJacsim = challenge
        challenge.stages.append(stage)
        challenge.currentStageType = nextType
        do {
            try context.save()
        } catch {
            print(error)
        }
        return stage
    }

    func updateTaskInfo(task: UserJacsim, title: String, success: Int, isAlarmEnabled: Bool, alarmDate: Date) {
        task.title = title
        task.success = success
        task.isNotificationEnabled = isAlarmEnabled
        task.alarm = isAlarmEnabled ? alarmDate : nil
        if isAlarmEnabled {
            scheduleAlarm(for: task)
        } else {
            removeAlarm(for: task)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
    }

    func needsMigrationV0_1() -> Bool {
        !UserDefaults.standard.bool(forKey: "jacsim.migration.v0_1")
    }

    private func notificationIdentifier(for task: UserJacsim) -> String {
        "jacsim-\(task.id.uuidString)"
    }

    private func scheduleAlarm(for task: UserJacsim) {
        guard task.isNotificationEnabled, let alarm = task.alarm, task.isDone == false else { return }
        let identifier = notificationIdentifier(for: task)
        removeAlarm(for: task)

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: alarm)
        dateComponents.calendar = Calendar.current

        let content = UNMutableNotificationContent()
        content.title = "작심 인증"
        content.body = "\(task.title) 인증할 시간이에요"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    private func removeAlarm(for task: UserJacsim) {
        let identifier = notificationIdentifier(for: task)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])

        if let alarm = task.alarm {
            let alarmString = DateFormatType.toString(alarm, to: .fullWithTime)
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(task.title)\(alarmString).starter", "\(task.title)\(alarmString).repeater"])
        }
    }

    func performMigrationV0_1() {
        guard needsMigrationV0_1() else { return }
        let tasks = fetchAllTasks()
        var didUpdate = false

        for task in tasks {
            if task.statusRaw.isEmpty {
                task.statusRaw = ChallengeStatus.inProgress.rawValue
                didUpdate = true
            }
            if task.resultRaw.isEmpty {
                task.resultRaw = ChallengeResult.none.rawValue
                didUpdate = true
            }
            if task.currentStageTypeRaw == 0 {
                task.currentStageTypeRaw = StageType.three.rawValue
                didUpdate = true
            }
            task.isNotificationEnabled = task.alarm != nil

            let stage = ensureInitialStage(for: task)
            let dailyRecords = migrateDailyRecords(for: task)
            if stage.dailyRecords.isEmpty {
                stage.dailyRecords = dailyRecords
                stage.successDays = dailyRecords.filter { $0.check }.count
                didUpdate = true
            }
        }

        if didUpdate {
            do {
                try context.save()
                UserDefaults.standard.set(true, forKey: "jacsim.migration.v0_1")
            } catch {
                print(error)
            }
        }
    }

    private func fetchAllTasks() -> [UserJacsim] {
        let descriptor = FetchDescriptor<UserJacsim>(sortBy: [SortDescriptor(\.startDate, order: .forward)])
        return (try? context.fetch(descriptor)) ?? []
    }

    private func ensureInitialStage(for task: UserJacsim) -> Stage {
        if let existing = task.stages.first {
            return existing
        }
        let startDate = task.startDate
        let durationDays = StageType.three.durationDays
        let endDate = Calendar.current.date(byAdding: .day, value: durationDays - 1, to: startDate)
            ?? startDate.addingTimeInterval(TimeInterval((durationDays - 1) * 86400))
        let stage = Stage(
            stageTypeRaw: StageType.three.rawValue,
            startDate: startDate,
            endDate: endDate,
            durationDays: durationDays
        )
        stage.userJacsim = task
        task.stages.append(stage)
        return stage
    }

    private func migrateDailyRecords(for task: UserJacsim) -> [Certified] {
        var migrated: [Certified] = []
        for (index, record) in task.memoList.enumerated() {
            let date = task.jacsimDayArray.indices.contains(index) ? task.jacsimDayArray[index] : task.startDate
            record.date = date
            let dateText = DateFormatType.toString(date, to: .fullWithoutYear)
            let fileName = "\(task.id)_\(dateText).jpg"

            if hasImageFile(named: fileName) {
                record.imagePath = fileName
            } else {
                record.imagePath = nil
                record.check = false
            }

            migrated.append(record)
        }
        return migrated
    }

    private func hasImageFile(named fileName: String) -> Bool {
        guard let imageDirectory = DocumentManager.shared.ImageDirectoryPath() else { return false }
        let fileURL = imageDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}
