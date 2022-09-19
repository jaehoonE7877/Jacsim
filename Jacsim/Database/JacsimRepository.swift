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
    func addItem(item: UserJacsim) 
}

final class JacsimRepository: JacsimRepositoryProtocol {
    
    let localRealm = try! Realm()
    
    // Home View에서 TableView에 보여주는 task
    func fetchRealm() -> Results<UserJacsim>! {
        return localRealm.objects(UserJacsim.self).where { $0.isDone == false }.sorted(byKeyPath: "startDate", ascending: true)
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
                item.memo[index] = memo
            }
        } catch let error {
            print(error)
        }
    }

}
