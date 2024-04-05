//
//  LimitTextField.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

protocol HasLemitLength: UITextField {
    var lemitCount: Int { get set }
    func setMaxLength()
}

open class LemitTextField: UITextField, HasLemitLength {
    public var lemitCount: Int
    
    public init(lemitCount: Int) {
        self.lemitCount = lemitCount
        super.init(frame: .zero)
        if lemitCount != 0 {
            self.setMaxLength()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LemitTextField {
    func setMaxLength() {
        objc_setAssociatedObject(self, &lemitCount, lemitCount, .OBJC_ASSOCIATION_RETAIN)
        addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
    }
    
    @objc
    private func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
              prospectiveText.count > lemitCount else { return }
        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: lemitCount)
        text = String(prospectiveText[..<maxCharIndex])
        selectedTextRange = selection
    }
}
