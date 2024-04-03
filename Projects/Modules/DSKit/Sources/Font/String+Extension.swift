//
//  String+Extension.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/3/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

public extension String {
//MARK: - HERO
    func hero(color: UIColor,
              alignment: NSTextAlignment = .left,
              lineBreakMode: NSLineBreakMode = .byWordWrapping,
              isStrikethrough: Bool = false,
              isUnderLine: Bool = false) -> NSAttributedString {
        let font = UIFont.pretendardBold(size: 36)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        if lineBreakMode == .byWordWrapping {
            paragraphStyle.lineBreakStrategy = .hangulWordPriority
        }
        
        let lineHeight: CGFloat = 45
        let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
        
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                         .baselineOffset: baselineOffset,
                                                         .foregroundColor: color,
                                                         .font: font,
                                                         .kern: -0.4]
        
        if isStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        if isUnderLine {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return NSAttributedString(string: self, attributes: attributes)
    }
//MARK: - HEADING1
    func heading1(color: UIColor,
              alignment: NSTextAlignment = .left,
              lineBreakMode: NSLineBreakMode = .byWordWrapping,
              isStrikethrough: Bool = false,
              isUnderLine: Bool = false) -> NSAttributedString {
        let font = UIFont.pretendardBold(size: 32)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        if lineBreakMode == .byWordWrapping {
            paragraphStyle.lineBreakStrategy = .hangulWordPriority
        }
        
        let lineHeight: CGFloat = 42
        let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
        
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                         .baselineOffset: baselineOffset,
                                                         .foregroundColor: color,
                                                         .font: font,
                                                         .kern: -0.4]
        
        if isStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        if isUnderLine {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return NSAttributedString(string: self, attributes: attributes)
    }
//MARK: - HEADING2
    func heading2(color: UIColor,
              alignment: NSTextAlignment = .left,
              lineBreakMode: NSLineBreakMode = .byWordWrapping,
              isStrikethrough: Bool = false,
              isUnderLine: Bool = false) -> NSAttributedString {
        let font = UIFont.pretendardBold(size: 24)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        if lineBreakMode == .byWordWrapping {
            paragraphStyle.lineBreakStrategy = .hangulWordPriority
        }
        
        let lineHeight: CGFloat = 32
        let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
        
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                         .baselineOffset: baselineOffset,
                                                         .foregroundColor: color,
                                                         .font: font,
                                                         .kern: -0.4]
        
        if isStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        if isUnderLine {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return NSAttributedString(string: self, attributes: attributes)
    }
//MARK: - HEADING3
    func heading3(color: UIColor,
              alignment: NSTextAlignment = .left,
              lineBreakMode: NSLineBreakMode = .byWordWrapping,
              isStrikethrough: Bool = false,
              isUnderLine: Bool = false) -> NSAttributedString {
        let font = UIFont.pretendardSemiBold(size: 20)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        if lineBreakMode == .byWordWrapping {
            paragraphStyle.lineBreakStrategy = .hangulWordPriority
        }
        
        let lineHeight: CGFloat = 26
        let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
        
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                         .baselineOffset: baselineOffset,
                                                         .foregroundColor: color,
                                                         .font: font,
                                                         .kern: -0.4]
        
        if isStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        if isUnderLine {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return NSAttributedString(string: self, attributes: attributes)
    }
//MARK: - HEADING4
    func heading4(color: UIColor,
              alignment: NSTextAlignment = .left,
              lineBreakMode: NSLineBreakMode = .byWordWrapping,
              isStrikethrough: Bool = false,
              isUnderLine: Bool = false) -> NSAttributedString {
        let font = UIFont.pretendardSemiBold(size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        if lineBreakMode == .byWordWrapping {
            paragraphStyle.lineBreakStrategy = .hangulWordPriority
        }
        
        let lineHeight: CGFloat = 22
        let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
        
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                         .baselineOffset: baselineOffset,
                                                         .foregroundColor: color,
                                                         .font: font,
                                                         .kern: -0.4]
        
        if isStrikethrough {
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        
        if isUnderLine {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return NSAttributedString(string: self, attributes: attributes)
    }
    //MARK: - BODY 1
        func body1(color: UIColor,
                  alignment: NSTextAlignment = .left,
                  lineBreakMode: NSLineBreakMode = .byWordWrapping,
                  isStrikethrough: Bool = false,
                  isUnderLine: Bool = false) -> NSAttributedString {
            let font = UIFont.pretendardMedium(size: 16)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            paragraphStyle.lineBreakMode = lineBreakMode
            if lineBreakMode == .byWordWrapping {
                paragraphStyle.lineBreakStrategy = .hangulWordPriority
            }
            
            let lineHeight: CGFloat = 22
            let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
            
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                             .baselineOffset: baselineOffset,
                                                             .foregroundColor: color,
                                                             .font: font,
                                                             .kern: -0.4]
            
            if isStrikethrough {
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
            
            if isUnderLine {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            return NSAttributedString(string: self, attributes: attributes)
        }
    //MARK: - BODY 2
        func body2(color: UIColor,
                  alignment: NSTextAlignment = .left,
                  lineBreakMode: NSLineBreakMode = .byWordWrapping,
                  isStrikethrough: Bool = false,
                  isUnderLine: Bool = false) -> NSAttributedString {
            let font = UIFont.pretendardRegular(size: 15)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            paragraphStyle.lineBreakMode = lineBreakMode
            if lineBreakMode == .byWordWrapping {
                paragraphStyle.lineBreakStrategy = .hangulWordPriority
            }
            
            let lineHeight: CGFloat = 18
            let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
            
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                             .baselineOffset: baselineOffset,
                                                             .foregroundColor: color,
                                                             .font: font,
                                                             .kern: -0.4]
            
            if isStrikethrough {
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
            
            if isUnderLine {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            return NSAttributedString(string: self, attributes: attributes)
        }
    //MARK: - BODY 3
        func body3(color: UIColor,
                  alignment: NSTextAlignment = .left,
                  lineBreakMode: NSLineBreakMode = .byWordWrapping,
                  isStrikethrough: Bool = false,
                  isUnderLine: Bool = false) -> NSAttributedString {
            let font = UIFont.pretendardRegular(size: 14)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            paragraphStyle.lineBreakMode = lineBreakMode
            if lineBreakMode == .byWordWrapping {
                paragraphStyle.lineBreakStrategy = .hangulWordPriority
            }
            
            let lineHeight: CGFloat = 17
            let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
            
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                             .baselineOffset: baselineOffset,
                                                             .foregroundColor: color,
                                                             .font: font,
                                                             .kern: -0.4]
            
            if isStrikethrough {
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
            
            if isUnderLine {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            return NSAttributedString(string: self, attributes: attributes)
        }
    //MARK: - caption
        func caption(color: UIColor,
                  alignment: NSTextAlignment = .left,
                  lineBreakMode: NSLineBreakMode = .byWordWrapping,
                  isStrikethrough: Bool = false,
                  isUnderLine: Bool = false) -> NSAttributedString {
            let font = UIFont.pretendardMedium(size: 12)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            paragraphStyle.lineBreakMode = lineBreakMode
            if lineBreakMode == .byWordWrapping {
                paragraphStyle.lineBreakStrategy = .hangulWordPriority
            }
            
            let lineHeight: CGFloat = 14
            let baselineOffset: CGFloat = (lineHeight - font.lineHeight) / 2.0 / 2.0
            
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            var attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                             .baselineOffset: baselineOffset,
                                                             .foregroundColor: color,
                                                             .font: font,
                                                             .kern: -0.4]
            
            if isStrikethrough {
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
            
            if isUnderLine {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            return NSAttributedString(string: self, attributes: attributes)
        }
}
