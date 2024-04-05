//
//  NSAttributedString+Extension.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/3/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

public extension UILabel {
    /**
     Label의 어트리뷰트 텍스트를 업데이트하기 위한것
     단 "" 이렇게 하면 안됨 최소 공백 하나는 있어야함
     Tag: #Label, #attributedText
     */
    func updateAttString(_ text: String) {
        guard let att = self.attributedText else { return }
        if att.length == 0 { return }
        let attributes = att.attributes(at: 0, effectiveRange: nil)
        self.attributedText = NSMutableAttributedString(string: text, attributes: attributes)
    }
}


public extension NSAttributedString {
    /**
     텍스트가 넓이 리턴
     */
    var labelWidth: CGFloat {
        if let font = self.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil) as? UIFont {
            let text = self.string as NSString
            return text.size(withAttributes: [.font: font]).width
        }
        return 0
    }
}

// MARK: - Properties
public extension NSMutableAttributedString {
    ///밑줄
    ///     Tag: #underline, #밑줄
    func underlined(_ value: String, fontSize: CGFloat, color: UIColor = .black) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes:[NSAttributedString.Key : Any] = [
            .font: font,
            .underlineStyle : NSUnderlineStyle.single.rawValue,
            .foregroundColor: color
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value: String, font: UIFont, color: UIColor = .black) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font: font,
            .underlineStyle : NSUnderlineStyle.single.rawValue,
            .foregroundColor: color
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    ///취소선
    ///     Tag: #strikeThrough, #취소선
    func strikeThrough(_ value: String, fontSize: CGFloat, color: UIColor = .black) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes:[NSAttributedString.Key : Any] = [
            .font: font,
            .strikethroughStyle : NSUnderlineStyle.single.rawValue,
            .foregroundColor: color
        ]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

// MARK: - Operators
public extension NSAttributedString {
    /// SwifterSwift: Add a NSAttributedString to another NSAttributedString.
    ///
    /// - Parameters:
    ///   - lhs: NSAttributedString to add to.
    ///   - rhs: NSAttributedString to add.
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        lhs = string
    }
    
    /// SwifterSwift: Add a NSAttributedString to another NSAttributedString and return a new NSAttributedString instance.
    ///
    /// - Parameters:
    ///   - lhs: NSAttributedString to add.
    ///   - rhs: NSAttributedString to add.
    /// - Returns: New instance with added NSAttributedString.
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        return NSAttributedString(attributedString: string)
    }
    
    /// SwifterSwift: Add a NSAttributedString to another NSAttributedString.
    ///
    /// - Parameters:
    ///   - lhs: NSAttributedString to add to.
    ///   - rhs: String to add.
    static func += (lhs: inout NSAttributedString, rhs: String) {
        lhs += NSAttributedString(string: rhs)
    }
    
    /// SwifterSwift: Add a NSAttributedString to another NSAttributedString and return a new NSAttributedString instance.
    ///
    /// - Parameters:
    ///   - lhs: NSAttributedString to add.
    ///   - rhs: String to add.
    /// - Returns: New instance with added NSAttributedString.
    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        return lhs + NSAttributedString(string: rhs)
    }
    
    func applying(attributes: [Key: Any]) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        
        let copy = NSMutableAttributedString(attributedString: self)
        copy.addAttributes(attributes, range: NSRange(0..<length))
        return copy
    }
}
