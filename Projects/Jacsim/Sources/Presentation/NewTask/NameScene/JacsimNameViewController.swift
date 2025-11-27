//
//  JacsimNameViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

import Core
import DSKit

import SnapKit
import Toast

final class JacsimNameViewController: BaseViewController {
    
    //MARK: - UIComponent
    private let titleLabel: UILabel = .init().then {
        $0.attributedText = "무엇을 작심하셨나요?".heading3(color: .labelStrong)
    }
    
    private let nameTextField: InputTextField = .init(limitCount: 20).then {
        $0.inputState = .none
        $0.placeHolderWithFont = "예시 - 아침에 일어나서 물 마시기"
    }
    
    private let limitCountLabel: UILabel = .init().then {
        let front = "0".body1(color: .labelAssistive, alignment: .right)
        let end = " / 20".body1(color: .labelAssistive, alignment: .right)
        $0.attributedText = front + end
    }
    
    private let nextButton = PrimaryButton(state: .disable,
                                           disableTouchWhenDisabled: true).then {
        $0.setAttributedTitle("다음".body1(color: .labelNormal, alignment: .center), for: .normal)
        $0.setAttributedTitle("다음".body1(color: .labelDisable, alignment: .center), for: .disabled)
    }
    
    private let viewModel: JacsimNameViewModel
    
    //MARK: - init
    
    init(viewModel: JacsimNameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    //MARK: - Life Cycle
    override func loadView() {
        super.loadView()
        bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObserver()
        applyNameState(viewModel.name)
    }
    
    override func setNavigationController() {
        super.setNavigationController()
        setBackButton(type: .dismiss)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bind() {
        nameTextField.addTarget(self, action: #selector(nameEditingDidBegin), for: .editingDidBegin)
        nameTextField.addTarget(self, action: #selector(nameEditingDidEnd), for: .editingDidEnd)
        nameTextField.addTarget(self, action: #selector(nameEditingChanged(_:)), for: .editingChanged)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
}

extension JacsimNameViewController {
    private func setObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.nextButton.snp.remakeConstraints { make in
                make.height.equalTo(52)
                make.bottom.equalToSuperview().inset(keyboardSize.height + 16)
                make.horizontalEdges.equalToSuperview().inset(16)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillHide(_ notification: NSNotification) {
        self.nextButton.snp.remakeConstraints { make in
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        self.view.layoutIfNeeded()
    }
}

// MARK: - Actions
extension JacsimNameViewController {
    @objc
    private func nameEditingChanged(_ sender: UITextField) {
        applyNameState(sender.text ?? "")
    }

    @objc
    private func nameEditingDidBegin() {
        nameTextField.inputState = .typing
    }

    @objc
    private func nameEditingDidEnd() {
        nameTextField.inputState = .none
    }

    @objc
    private func nextButtonTapped() {
        guard let jacsim = viewModel.makeJacsimDTO() else { return }
        Log(jacsim)
    }

    private func applyNameState(_ text: String) {
        let result = viewModel.updateName(text)
        let countAtt = result.countText.body1(color: .labelAssistive, alignment: .right)
        let limitAtt = " / 20".body1(color: .labelAssistive, alignment: .right)
        limitCountLabel.attributedText = countAtt + limitAtt
        nextButton.buttonState = result.isValid ? .enable : .disable
    }
}

extension JacsimNameViewController {
    private func setView() {
        self.view.addSubviews([titleLabel, nameTextField, limitCountLabel, nextButton])
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.height.equalTo(65)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        limitCountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel)
            make.trailing.equalTo(nameTextField)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
