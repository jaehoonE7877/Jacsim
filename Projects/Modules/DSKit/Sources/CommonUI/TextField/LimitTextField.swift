//
//  LimitTextField.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

protocol HasLimitLength: UITextField {
    var limitCount: Int { get set }
    func setMaxLength()
}

open class LimitTextField: UITextField, HasLimitLength {
    public var limitCount: Int
    
    public init(limitCount: Int) {
        self.limitCount = limitCount
        super.init(frame: .zero)
        if limitCount != 0 {
            self.setMaxLength()
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LimitTextField {
    func setMaxLength() {
        objc_setAssociatedObject(self, &limitCount, limitCount, .OBJC_ASSOCIATION_RETAIN)
        addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
    }
    
    @objc
    private func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
              prospectiveText.count > limitCount else { return }
        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: limitCount)
        text = String(prospectiveText[..<maxCharIndex])
        selectedTextRange = selection
    }
}
