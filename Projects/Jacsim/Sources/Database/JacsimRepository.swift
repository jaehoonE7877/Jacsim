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

protocol JacsimRepositoryProtocol: AnyObject {
    func fetchActiveTasks() -> [UserJacsim]
    func fetchIsSuccess() -> [UserJacsim]
    func fetchIsFail() -> [UserJacsim]
    func fetchDate(date: Date) -> [UserJacsim]
    func fetchIsNotDone() -> Int
    func addJacsim(item: UserJacsim)
    func updateMemo(item: UserJacsim, index: Int, memo: String)
    func removeImageFromDocument(fileName: String)
    func deleteJacsim(item: UserJacsim)
    func deleteAlarm(item: UserJacsim)
    func checkIsDone(item: UserJacsim, count: Int)
    func checkIsDone(items: [UserJacsim])
    func checkCertified(item: UserJacsim) -> Int
    func checkIsSuccess(item: UserJacsim)
}

@MainActor
final class JacsimRepository: JacsimRepositoryProtocol {

    static let shared = JacsimRepository()
    private init() {
        let schema = Schema([UserJacsim.self, Certified.self])
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
        } catch {
            print(error)
        }
    }

    func deleteAlarm(item: UserJacsim) {
        guard let alarm = item.alarm else { return }
        let alarmString = alarm.convertToString(withFormat: .yyyyMDEEEEahhmm)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(item.title)\(alarmString).starter", "\(item.title)\(alarmString).repeater"])

        item.alarm = nil
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
        if let alarm = item.alarm {
            removeImageFromDocument(fileName: "\(item.id).jpg")
            let alarmString = DateFormatType.toString(alarm, to: .fullWithTime)
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(item.title)\(alarmString).starter", "\(item.title)\(alarmString).repeater"])
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

                if let alarm = task.alarm {
                    let alarmString = DateFormatType.toString(alarm, to: .fullWithTime)
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(task.title)\(alarmString).repeater"])
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
}
