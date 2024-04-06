//
//  InputTextField.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

open class InputTextField: LimitTextField {
    //MARK: -- StateAttribute
    public enum StateAttribute {
        case none
        case typing
        case warning
        
        var warningColor: UIColor {
            switch self {
            case .none: return .labelDisable
            case .typing: return .labelStrong
            case .warning: return .destructive
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .none: return 1
            case .typing: return 1
            case .warning: return 1
            }
        }
    }
    
    public var textFieldText: String {
        get { self.text ?? "" }
        set { self.attributedText = newValue.body1(color: .labelNormal) }
    }
    
    public var inputState: StateAttribute = .none {
        didSet {
            updateState(state: inputState)
        }
    }
    
    public var placeHolderWithFont: String {
        get { return self.placeholder ?? "" }
        set {
            self.attributedPlaceholder = newValue.body1(color: .labelNeutral)
        }
    }
    
    private var padding: UIEdgeInsets
    
    public init(limitCount: Int = 0, padding: UIEdgeInsets = .init(top: 9, left: 12,
                                       bottom: 9, right: 12)) {
        self.padding = padding
        super.init(limitCount: limitCount)
        self.layer.cornerRadius = 8
        self.font = .pretendardMedium(size: 16)
        self.textColor = .labelNormal
    }
    
    public required init?(coder: NSCoder) {
        self.padding = .zero
        super.init(coder: coder)
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension InputTextField {
    private func updateState(state: StateAttribute) {
        self.layer.borderWidth = state.borderWidth
        self.layer.borderColor = state.warningColor.cgColor
    }
}
