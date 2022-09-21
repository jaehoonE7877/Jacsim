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
    
    let localRealm = try! Realm()
    
    func fetchRealm() -> Results<UserJacsim>! {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == false }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsDone() -> Results<UserJacsim>! {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == true }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsNotDone() -> Int {
        return localRealm.objects(UserJacsim.self).where({$0.isDone == false }).count 
    }
    
    // Home View에서 TableView에 보여주는 task
    func fetchDate(date: Date) -> Results<UserJacsim>! {
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
        //url로 저자
        if item.mainImage != nil {
            do {
                try localRealm.write{
                    localRealm.delete(item.memoList)
                    localRealm.delete(item)
                }
            } catch {
                print(error)
            }
        } else {
            //이미지 docu에 저장
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

}
