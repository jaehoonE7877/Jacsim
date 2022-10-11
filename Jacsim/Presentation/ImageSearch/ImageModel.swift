//
//  ImageModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/16.
//

import Foundation

struct ImageModel: Codable {
    let total: Int
    let items: [Item]
    
}

struct Item: Codable {
    let link: String
    
}
