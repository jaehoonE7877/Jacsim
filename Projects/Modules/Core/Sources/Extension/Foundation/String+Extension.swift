//
//  String+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

public extension String {
    func convertToDate(format: DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = .KR
        dateFormatter.locale = .KR
        let date = dateFormatter.date(from: self) ?? Date()
        return date
    }
}
