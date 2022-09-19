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
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    @Persisted var title: String
    @Persisted var startDate: Date
    @Persisted var endDate: Date
    @Persisted var mainImage: String?
    @Persisted var isDone: Bool

    @Persisted var memo: List<String>

    convenience init(title: String, startDate: Date, endDate: Date, mainImage: String?, isDone: Bool, memo: List<String>) {
        self.init()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.mainImage = mainImage
        self.isDone = false
        self.memo = memo
    }
    
}

//class Certified: Object {
//    @Persisted var memo: String
//}
