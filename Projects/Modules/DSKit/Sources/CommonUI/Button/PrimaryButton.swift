//
//  PrimaryButton.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit
/**
 PrimaryButton
 
 Public Property
 ```
 var buttonTitle: NSAttributedString { get set }
 //상태에따라 조절
 override var isEnabled: Bool
 ```
 
 Note:
  - 유동값 : 버튼 높이,너비 /  버튼 radius /  텍스트 컬러
 
  - 고정값 :   폰트스타일  /  버튼 상태값(활성화, 비활성화) /  버튼 컬러
 
 [사용법 예시]
 ```swift
 let bt: PrimaryButton = .init().then {
    $0.setAttributedTitle("text".body1(color: .gray90), for: .normal)
    $0.layer.cornerRadius = 10
 }
 ```
 Author: 서재훈
 Tag: #UIButton
 */
public final class PrimaryButton: UIButton {
    public enum State {
        case enable
        case disable
    }
    //MARK: -- Button Attribute
    private let buttonEnableBackground: UIColor = .primaryNormal
    private let buttonDisableBackground: UIColor = .primaryNormal.withAlphaComponent(0.28)
    
    //MARK: -- Private
    private let buttonTitleLabel: UILabel = .init().then {
        $0.isUserInteractionEnabled = false
    }
    
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
        
        buttonTitleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
