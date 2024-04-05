//
//  String+Extension.swift
//  Core
//
//  Created by Seo Jae Hoon on 4/5/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

public extension String {
    /**
     문자열이 비어있는지 확인합니다.
     */
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    func convertToDate(format: DateFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = .KR
        dateFormatter.locale = .KR
        let date = dateFormatter.date(from: self) ?? Date()
        return date
    }
}

public extension String {
    /**
     문자열을 정수로 변환합니다.
     
     - Returns: 변환된 정수 값.
     */
    func toInt() -> Int {
        return Int(self) ?? 0
    }
    /**
     문자열을 실수로 변환합니다.
     
     - Returns: 변환된 실수 값.
     */
    func toDouble() -> Double {
        return Double(self) ?? 0
    }
    
    /**
     숫자만 필터링된 문자열을 반환합니다.
     - Returns: 숫자만 포함된 문자열
     */
    var decimalFilteredString: String {
        return String(unicodeScalars.filter(CharacterSet.decimalDigits.contains))
    }
    
    /**
     지정된 패턴에 맞게 문자열을 포맷팅합니다.
     - Parameters:
        - patternString: 패턴 문자열. 숫자 자리는 "#"으로 표시합니다.
     - Returns: 포맷팅된 문자열
     */
    func formated(by patternString: String) -> String {
            let digit: Character = "#"
     
            let pattern: [Character] = Array(patternString)
            let input: [Character] = Array(self.decimalFilteredString)
            var formatted: [Character] = []
     
            var patternIndex = 0
            var inputIndex = 0
     
            while inputIndex < input.count {
                let inputCharacter = input[inputIndex]
                
                guard patternIndex < pattern.count else { break }
                switch pattern[patternIndex] == digit {
                case true:
                    formatted.append(inputCharacter)
                    inputIndex += 1
                case false:
                    formatted.append(pattern[patternIndex])
                }
                 patternIndex += 1
            }
            return String(formatted)
        }
}
