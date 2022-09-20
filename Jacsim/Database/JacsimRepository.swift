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
    func addItem(item: UserJacsim)
    func updateMemo(item: UserJacsim, index: Int, memo: String)
}

final class JacsimRepository: JacsimRepositoryProtocol {
    
    let localRealm = try! Realm()
    
    func fetchRealm() -> Results<UserJacsim>! {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == false }.sorted(byKeyPath: "startDate", ascending: true)
    }
    
    func fetchIsNotDone() -> Int {
        return localRealm.objects(UserJacsim.self).where({$0.isDone == false }).count 
    }
    
    // Home View에서 TableView에 보여주는 task
    func fetchDate(date: Date) -> Results<UserJacsim>! {
        //NSPredicate
        return localRealm.objects(UserJacsim.self).where{ $0.isDone == false }.filter("endDate >= %@ AND startDate < %@", date, Date(timeInterval: 86400, since: date)).sorted(byKeyPath: "startDate", ascending: true)
    }

    func addItem(item: UserJacsim) {
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

}
