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
    
    @Persisted var jacsimTitle: String
    @Persisted var startDate: Date
    @Persisted var endDate: Date
    @Persisted var mainImage: String
    @Persisted var isDone: Bool
    @Persisted var nickName: String = "Nickname"
    
    var certified = List<CertifiedObject>()
    
    
    convenience init(jacsimTitle: String, startDate: Date, endDate: Date, mainImage: String, isDone: Bool) {
        self.init()
        self.jacsimTitle = jacsimTitle
        self.startDate = startDate
        self.endDate = endDate
        self.mainImage = mainImage
        self.isDone = false
        
        
    }
    
}

class CertifiedObject: Object {
    
    dynamic var certifiedImage: UIImage?
    dynamic var certifiedMemo: String?
    
}
