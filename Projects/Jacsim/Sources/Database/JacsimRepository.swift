//
//  Repository.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/17.
//

import Foundation
import UserNotifications

import RealmSwift

/*
 레포의 역할 
 */

protocol JacsimRepositoryProtocol: AnyObject {
    func fetchRealm() -> Results<UserJacsim>
    func fetchDate(date: Date) -> Results<UserJacsim>
    func addJacsim(item: UserJacsim)
    func updateMemo(item: UserJacsim, index: Int, memo: String)
    func removeImageFromDocument(fileName: String)
    func deleteJacsim(item: UserJacsim)
    func deleteAlarm(item: UserJacsim)
    func checkIsDone(item: UserJacsim, count: Int)
    func checkCertified(item: UserJacsim) -> Int
    func checkIsSuccess(item: UserJacsim)
}

final class JacsimRepository: JacsimRepositoryProtocol {
    
    static let shared = JacsimRepository()
    private init() { }
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    private var localRealm: Realm {
        get {
            do {
                let realm = try Realm()
                return realm
            } catch {
                print("\(error.localizedDescription)")
                return try! Realm()
            }
        }
    }
    
    func fetchId(id: ObjectId) -> Results<UserJacsim> {
        return localRealm.objects(UserJacsim.self).where { $0.id == id }
    }
    
    func fetchRealm() -> Results<UserJacsim> {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == false }.sorted(byKeyPath: "startDate", ascending: true)
    }
    // 이후엔 안 쓸 것
    func fetchIsDone() -> Results<UserJacsim> {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == true }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsSuccess() -> Results<UserJacsim> {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == true }.where { $0.isSuccess == true }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsFail() -> Results<UserJacsim> {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == true }.where { $0.isSuccess == false }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsNotDone() -> Int {
        return localRealm.objects(UserJacsim.self).where({$0.isDone == false }).count
    }
    
    // Home View에서 TableView에 보여주는 task
    func fetchDate(date: Date) -> Results<UserJacsim> {
        //NSPredicate
        return localRealm.objects(UserJacsim.self).where{ $0.isDone == false }.filter("endDate >= %@ AND startDate < %@", date, Date(timeInterval: 86400, since: date)).sorted(byKeyPath: "startDate", ascending: true)
    }

    func addJacsim(item: UserJacsim) {
        do {
            try localRealm.write{
                localRealm.add(item)
            }
        } catch let error {
            print(error)
        }
    }
    
    func deleteAlarm(item: UserJacsim) {
       
        guard let alarm = item.alarm else { return }
        let alarmString = DateFormatType.toString(alarm, to: .fullWithTime)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(item.title)\(alarmString).starter", "\(item.title)\(alarmString).repeater"])
        
        do {
            try localRealm.write{
                item.alarm = nil
            }
        } catch let error {
            print(error)
        }
    }
    
    func updateMemo(item: UserJacsim, index: Int, memo: String){
        do {
            try localRealm.write{
                item.memoList[index].memo = memo
                item.memoList[index].check = true
            }
        } catch let error {
            print(error)
        }
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
            
            do {
                try localRealm.write{
                    localRealm.delete(item.memoList)
                    localRealm.delete(item)
                }
            } catch {
                print(error)
            }
        } else {
            removeImageFromDocument(fileName: "\(item.id).jpg")
            
            do {
                try localRealm.write{
                    localRealm.delete(item.memoList)
                    localRealm.delete(item)
                }
            } catch {
                print(error)
            }
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
            do {
                try localRealm.write{
                    item.isDone = true
                }
            } catch let error {
                print(error)
            }
        }
    }
    // 종료일이 지남으로서 isDone 정의
    func checkIsDone(items: [UserJacsim]) {
        
        items.forEach { task in
            let end = task.endDate + 86400
           // print(now, end )
            if Date() - end >= 0 {
                do {
                    try localRealm.write{
                        task.isDone = true
                        
                        if let alarm = task.alarm {
                            let alarmString = DateFormatType.toString(alarm, to: .fullWithTime)
                            notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(task.title)\(alarmString).repeater"])
                        }
                        
                    }
                } catch let error {
                    print(error)
                }
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
            do {
                try localRealm.write{
                    item.isSuccess = true
                    
                }
            } catch let error {
                print(error)
            }
        }
    }
}
