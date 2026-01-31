//
//  PrimaryButton.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

public final class PrimaryButton: UIButton {
    public enum State {
        case enable
        case disable
    }

    private let buttonEnableBackground: UIColor = .primaryNormal
    private let buttonDisableBackground: UIColor = .primaryNormal.withAlphaComponent(0.28)

    private let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let disableWhenStateDisable: Bool

    //MARK: -- Public Property
    public var buttonTitle: NSAttributedString {
        get { self.buttonTitleLabel.attributedText ?? .init(string: self.buttonTitleLabel.text ?? "") }
        set { buttonTitleLabel.attributedText = newValue }
    }
    
    public var buttonState: State {
        didSet {
            self.setButtonAttribute(state: buttonState)
        }
    }
    
    //MARK: -- init()
    public init(state: State, disableTouchWhenDisabled: Bool) {
        self.disableWhenStateDisable = disableTouchWhenDisabled
        self.buttonState = state
        super.init(frame: .zero)
        self.setButtonAttribute(state: state)
        self.setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PrimaryButton {
    private func setButtonAttribute(state: State) {
        let backgroundColor = state == .enable ? self.buttonEnableBackground : self.buttonDisableBackground
        self.backgroundColor = backgroundColor
        if disableWhenStateDisable == true {
            self.isUserInteractionEnabled = state == .enable
        } else {
            self.isUserInteractionEnabled = true
        }
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    private func setView() {
        self.addSubview(buttonTitleLabel)
        buttonTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonTitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
