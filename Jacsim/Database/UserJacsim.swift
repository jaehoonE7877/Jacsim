//
//  RealmModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import Foundation

import RealmSwift
import UIKit

class UserJacsim: Object {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var title: String
    @Persisted var startDate: Date
    @Persisted var endDate: Date
    @Persisted var isDone: Bool
    @Persisted var success: Int
    @Persisted var isSuccess: Bool
    //@Persisted var alarm: Date?

    @Persisted var memoList: List<Certified>

    convenience init(title: String, startDate: Date, endDate: Date, isDone: Bool = false, success: Int, isSuccess: Bool = false) {
        self.init()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isDone = isDone
        self.success = success
        self.isSuccess = isSuccess
        //self.alarm = alarm
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class Certified: Object {
   
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var memo: String
    @Persisted var check: Bool
    
    let forUserjacsim = LinkingObjects(fromType: UserJacsim.self, property: "memo")
    
    convenience init(memo: String) {
        self.init()
        self.memo = memo
        self.check = false
    }
}
