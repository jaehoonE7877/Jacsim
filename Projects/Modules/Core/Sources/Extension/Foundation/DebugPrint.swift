//
//  DebugPrint.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

public func Log<T>(_ object: T?, filename: String = #file, line: Int = #line, funcName: String = #function) {
    #if !RELEASE
    let date = Date()
    let dateFormmat = DateFormatter()
    dateFormmat.calendar = .current
    dateFormmat.dateFormat = "디버깅 로그 YYYY-MM-dd hh:mm:ss"
    let formatDate = dateFormmat.string(from: date)
    if let obj = object {
        print("\(formatDate) \(filename.components(separatedBy: "/").last ?? "")(\(line)) : \(funcName) : \(obj)")
    } else {
        print("\(formatDate) \(filename.components(separatedBy: "/").last ?? "")(\(line)) : \(funcName) : nil")
    }
    #endif
}
