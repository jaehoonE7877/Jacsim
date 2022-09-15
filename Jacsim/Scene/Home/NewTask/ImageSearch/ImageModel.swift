//
//  ImageModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/16.
//

import Foundation

struct ImageModel: Codable {
    let total: Int
    let items: [Result]
    
}

struct Result: Codable {
    let link: String
    
}
