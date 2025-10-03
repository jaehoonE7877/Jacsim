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
    func fetchAllActive() -> [UserJacsim]
    func fetchIsSuccess() -> [UserJacsim]
    func fetchIsFail() -> [UserJacsim]
    func fetchDate(date: Date) -> [UserJacsim]
    func addJacsim(item: UserJacsim)
    func updateMemo(item: UserJacsim, index: Int, memo: String)
    func removeImageFromDocument(fileName: String)
    func deleteJacsim(item: UserJacsim)
    func deleteAlarm(item: UserJacsim)
    func checkIsDone(item: UserJacsim, count: Int)
    func checkIsDone(items: [UserJacsim])
    func checkCertified(item: UserJacsim) -> Int
    func checkIsSuccess(item: UserJacsim)
    func fetchIsNotDone() -> Int
}

final class JacsimRepository: JacsimRepositoryProtocol {
    
    static let shared = JacsimRepository()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    private let container: ModelContainer = {
        let schema = Schema([UserJacsim.self, Certified.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
    private let context: ModelContext
    
    private init() {
        self.context = ModelContext(container)
    }

    func fetchAllActive() -> [UserJacsim] {
        let descriptor = FetchDescriptor<UserJacsim>(predicate: #Predicate { !$0.isDone }, sortBy: [SortDescriptor(\UserJacsim.startDate, order: .forward)])
        return (try? context.fetch(descriptor)) ?? []
    }
    func fetchIsSuccess() -> [UserJacsim] {
        let descriptor = FetchDescriptor<UserJacsim>(predicate: #Predicate { $0.isDone && $0.isSuccess }, sortBy: [SortDescriptor(\UserJacsim.startDate, order: .forward)])
        return (try? context.fetch(descriptor)) ?? []
    }
    func fetchIsFail() -> [UserJacsim] {
        let descriptor = FetchDescriptor<UserJacsim>(predicate: #Predicate { $0.isDone && !$0.isSuccess }, sortBy: [SortDescriptor(\UserJacsim.startDate, order: .forward)])
        return (try? context.fetch(descriptor)) ?? []
    }
    func fetchIsNotDone() -> Int {
        let descriptor = FetchDescriptor<UserJacsim>(predicate: #Predicate { !$0.isDone })
        return ((try? context.fetchCount(descriptor)) ?? 0)
    }
    func fetchDate(date: Date) -> [UserJacsim] {
        let endOfDay = Date(timeInterval: 86400, since: date)
        let predicate = #Predicate<UserJacsim> { !$0.isDone && $0.endDate >= date && $0.startDate < endOfDay }
        let descriptor = FetchDescriptor<UserJacsim>(predicate: predicate, sortBy: [SortDescriptor(\UserJacsim.startDate, order: .forward)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func addJacsim(item: UserJacsim) {
        context.insert(item)
        try? context.save()
    }
    
    func deleteAlarm(item: UserJacsim) {
       
        guard let alarm = item.alarm else { return }
        let alarmString = alarm.convertToString(withFormat: .yyyyMDEEEEahhmm)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(item.title)\(alarmString).starter", "\(item.title)\(alarmString).repeater"])
        
        item.alarm = nil
        try? context.save()
    }
    
    func updateMemo(item: UserJacsim, index: Int, memo: String) {
        guard item.memoList.indices.contains(index) else { return }
        item.memoList[index].memo = memo
        item.memoList[index].check = true
        try? context.save()
    }
    
    func removeImageFromDocument(fileName: String) {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return } //Document 경로
        let imageDirectory = documentDirectory.appendingPathComponent("Image")
        let fileURL = imageDirectory.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            print(error)
        }
    }
    
    func deleteJacsim(item: UserJacsim) {
        
        if let alarm = item.alarm {
            removeImageFromDocument(fileName: "\(item.id).jpg")
            let alarmString = DateFormatType.toString(alarm, to: .fullWithTime)
            //print("\(item.title)\(alarmString).starter", "\(item.title)\(alarmString).repeater")
            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(item.title)\(alarmString).starter", "\(item.title)\(alarmString).repeater"])
            
            context.delete(item)
            try? context.save()
        } else {
            removeImageFromDocument(fileName: "\(item.id).jpg")
            
            context.delete(item)
            try? context.save()
        }
        
    }
    //종료일 전에 인증 개수로 isDone 정의
    func checkIsDone(item: UserJacsim, count: Int) {
        var cnt = 0
        item.memoList.forEach { value in
            if value.check {
                cnt += 1
            }
        }
        if cnt == count {
            item.isDone = true
            try? context.save()
        }
    }
    // 종료일이 지남으로서 isDone 정의
    func checkIsDone(items: [UserJacsim]) {
        
        items.forEach { task in
            let end = task.endDate + 86400
           // print(now, end )
            if Date() - end >= 0 {
                do {
                    task.isDone = true
                    if let alarm = task.alarm {
                        let alarmString = DateFormatType.toString(alarm, to: .fullWithTime)
                        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(task.title)\(alarmString).repeater"])
                    }
                    try? context.save()
                } catch { }
            }
        }
    }

    //인증 개수 확인
    func checkCertified(item: UserJacsim) -> Int {
        var cnt = 0
        item.memoList.forEach { value in
            if value.check {
                cnt += 1
            }
        }
        return cnt
    }
    
    func checkIsSuccess(item: UserJacsim) {
        
        if self.checkCertified(item: item) >= item.success {
            item.isSuccess = true
            try? context.save()
        }
    }
}
