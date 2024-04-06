//
//  UserJacsimVO.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

import Core

public struct UserJacsimDTO {
    public var title: String
    public var startDate: Date
    public var endDate: Date
    public var minSuccessCount: Int
    public var alarm: Date?
    
    public var mainImage: Data
    
    /// 새로운 작심 만들때 사용
    public init(title: String,
                startDate: Date = Date(),
                endDate: Date = Date(),
                minSuccessCount: Int = 1,
                alarm: Date? = nil,
                mainImage: Data = .init()) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.minSuccessCount = minSuccessCount
        self.alarm = alarm
        self.mainImage = mainImage
    }
    
    mutating public func updateDate(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    mutating public func updateMinSuccessCount(_ minSuccessCount: Int) {
        self.minSuccessCount = minSuccessCount
    }
    
    mutating public func updateMainImageData(_ data: Data) {
        self.mainImage = data
    }
    
    mutating public func updateAlarm(_ date: Date) {
        self.alarm = date
    }
}
