//
//  Repository.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/17.
//

import Foundation
import RealmSwift

private protocol JacsimRepositoryProtocol: AnyObject {
    func fetchRealm() -> Results<UserJacsim>!
    func fetchDate(date: Date) -> Results<UserJacsim>!
    func addJacsim(item: UserJacsim)
    func updateMemo(item: UserJacsim, index: Int, memo: String)
    func removeImageFromDocument(fileName: String)
    func deleteJacsim(item: UserJacsim)
    func checkIsDone(item: UserJacsim, count: Int)
    func checkCertified(item: UserJacsim) -> Int
}

final class JacsimRepository: JacsimRepositoryProtocol {
    
    let formatter = DateFormatter()
    let calendar = Calendar.current
    let now = Date()
    
    let localRealm = try! Realm()
    
    func fetchRealm() -> Results<UserJacsim>! {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == false }.sorted(byKeyPath: "startDate", ascending: true)
    }
    // 이후엔 안 쓸 것
    func fetchIsDone() -> Results<UserJacsim>! {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == true }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsSuccess() -> Results<UserJacsim>! {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == true }.where { $0.isSuccess == true }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsFail() -> Results<UserJacsim>! {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == true }.where { $0.isSuccess == false }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsNotDone() -> Int {
        return localRealm.objects(UserJacsim.self).where({$0.isDone == false }).count
    }
    
    // Home View에서 TableView에 보여주는 task
    func fetchDate(date: Date) -> Results<UserJacsim>! {
        //NSPredicate
        return localRealm.objects(UserJacsim.self).where{ $0.isDone == false }.filter("endDate >= %@ AND startDate < %@", date, Date(timeInterval: 86400, since: date)).sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchAlarm(task: UserJacsim) -> Bool {
       
        var dayArray: [Date] = []
        
        for date in stride(from: task.startDate, to: task.endDate + 86400, by: 86400 ){
            dayArray.append(date)
        }
        print(dayArray)
        print(now)
        var check: Bool = true
        
        print("시작일이 현재시간보다 빠르면 트루 \(now - task.startDate >= 0)")
        print("종료일 \(task.endDate - now >= 0)")
        
        if (now - task.startDate >= 0) && (task.endDate - now >= 0) {
            
            for index in 0...dayArray.count - 1 {
                
                if dayArray[index].toString() == now.toString() {
                    print(dayArray[index])
                    print(task.memoList[index].check)
                    check = task.memoList[index].check
                }
            }
        }
        return check
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
    
    func deleteJacsim(item: UserJacsim){
        
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
    func checkIsDone(items: Results<UserJacsim>!) {
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        formatter.string(from: now)
        
        items.forEach { task in
            let end = task.endDate + 86400
           // print(now, end )
            if now - end >= 0 {
                do {
                    try localRealm.write{
                        task.isDone = true
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
