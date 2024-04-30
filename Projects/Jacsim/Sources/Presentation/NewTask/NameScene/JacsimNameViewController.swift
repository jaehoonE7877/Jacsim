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
        let input = JacsimNameViewModel.Input(jacsimTitleText: self.nameTextField.rx.text.orEmpty.distinctUntilChanged(),
                                              nextButtonTap: self.nextButton.rx.tap.asObservable())
        let output = self.viewModel.transform(input: input)
        
        nameTextField.rx.controlEvent(.editingDidBegin)
            .asDriverOnErrorWithNever()
            .drive(with: self, onNext: { _self, _ in
                _self.nameTextField.inputState = .typing
            })
            .disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidEnd)
            .asDriverOnErrorWithNever()
            .drive(with: self, onNext: { _self, _ in
                _self.nameTextField.inputState = .none
            })
            .disposed(by: disposeBag)
        
        output.nextButtonValidation
            .drive(with: self, onNext: { _self, valid in
                _self.nextButton.buttonState = valid ? .enable : .disable
            })
            .disposed(by: disposeBag)
        
        output.showJacsimImageView
            .drive(with: self, onNext: { _self, jacsim in
                let viewModel = JacsimImageViewModel(jacsim: jacsim)
                let vc = JacsimImageViewController(viewModel: viewModel)
                _self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.textCount
            .drive(with: self, onNext: { _self, count in
                let countAtt = count.body1(color: .labelAssistive, alignment: .right)
                let limitAtt = " / 20".body1(color: .labelAssistive, alignment: .right)
                _self.limitCountLabel.attributedText = countAtt + limitAtt
            })
            .disposed(by: disposeBag)
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
