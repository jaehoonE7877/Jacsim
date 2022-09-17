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
    @Persisted var mainImage: Data?
    @Persisted var isDone: Bool
    
    var certified = List<Certified>()
    
    
    
    convenience init(title: String, startDate: Date, endDate: Date, mainImage: Data?, isDone: Bool) {
        self.init()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.mainImage = mainImage
        self.isDone = false
    }
    
}

class Certified: Object {
    @Persisted var image: Data?
    @Persisted var memo: String
    
    convenience init(image: Data?, memo: String){
        self.init()
        self.image = image
        self.memo = memo
    }
    
}
