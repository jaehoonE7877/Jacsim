//
//  NewTaskView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class NewTaskView: BaseView {
    
            // MARK: Property
    
    let newTaskTitleLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 18)
        $0.textColor = Constant.BaseColor.textColor
        $0.text = "작심한 일의 제목을 입력해주세요."
    }
    
    let titleCountLabel = UILabel().then {
        $0.font = .gothic(style: .Light, size: 14)
        $0.textColor = Constant.BaseColor.textColor
        $0.text = "0/20"
    }
    
    let newTaskTitleTextfield = UITextField().then {
        $0.backgroundColor = Constant.BaseColor.placeholderColor
        $0.setPlaceholder(text: "예시 - 아침에 일어나서 물 마시기")
        $0.textAlignment = .center
        $0.textColor = Constant.BaseColor.placeholderText
        $0.font = UIFont.gothic(style: .Light, size: 14)
    }
    
    let newTaskImageLabel = UILabel().then {
        $0.font = .gothic(style: .Medium, size: 18)
        $0.textColor = Constant.BaseColor.textColor
        $0.text = "작심한 일의 대표 이미지를 정해주세요."
    }
    
    let newTaskImageView = UIImageView().then {
        $0.backgroundColor = Constant.BaseColor.placeholderColor
    }
    
    let imageAddButton = UIButton(type: .system).then {
        $0.showsMenuAsPrimaryAction = true
    }
    
    let imageAddView = UIImageView().then {
        $0.image = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        $0.tintColor = Constant.BaseColor.buttonColor
    }
    
    let startDateLabel = UILabel().then {
        $0.font = .gothic(style: .Medium, size: 18)
        $0.textColor = Constant.BaseColor.textColor
        $0.text = "시작일"
    }
    
    let startDateTextField = UITextField().then {
        $0.setPlaceholder(text: "시작일을 정해주세요")
        $0.textColor = Constant.BaseColor.placeholderText
        $0.font = UIFont.gothic(style: .Light, size: 14)
        $0.textAlignment = .center
        $0.backgroundColor = Constant.BaseColor.placeholderColor
    }
    
    let endDateLabel = UILabel().then {
        $0.font = .gothic(style: .Medium, size: 18)
        $0.textColor = Constant.BaseColor.textColor
        $0.text = "종료일"
    }
    
    let endDateTextField = UITextField().then {
        $0.textColor = Constant.BaseColor.placeholderText
        $0.font = UIFont.gothic(style: .Light, size: 14)
        $0.textAlignment = .center
        $0.setPlaceholder(text: "종료일을 정해주세요")
        $0.backgroundColor = Constant.BaseColor.placeholderColor
    }
    
    let successLabel = UILabel().then {
        $0.text = "성공 기준 횟수를 정해주세요."
        $0.font = .gothic(style: .Medium, size: 18)
        $0.textColor = Constant.BaseColor.textColor
    }
    
    let successTextField = UITextField().then {
        $0.textAlignment = .center
        $0.backgroundColor = Constant.BaseColor.placeholderColor
        $0.keyboardType = .numberPad
        $0.addDoneButtonOnKeyboard()
        $0.text = "1"
        $0.textColor = Constant.BaseColor.placeholderText
        $0.font = UIFont.gothic(style: .Light, size: 16)
    }
    let successCountLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 16)
        $0.textColor = Constant.BaseColor.textColor
        $0.text = "회"
    }
    
    // MARK: StackView 생성
    lazy var topHorizontalStackView = UIStackView(arrangedSubviews: [newTaskTitleLabel, titleCountLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        newTaskTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        titleCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    lazy var startDateStackView = UIStackView(arrangedSubviews: [startDateLabel, startDateTextField]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
        
        startDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        startDateTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    lazy var endDateStackView = UIStackView(arrangedSubviews: [endDateLabel, endDateTextField]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
        
        endDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        endDateTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    lazy var successStackView = UIStackView(arrangedSubviews: [successTextField, successCountLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
        
        successTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        successCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func configure() {
        [topHorizontalStackView, newTaskTitleTextfield, newTaskImageLabel, newTaskImageView, imageAddButton, imageAddView, startDateStackView, endDateStackView, successLabel, successStackView].forEach{ self.addSubview($0) }
    }
    //MARK: Constraints 
    override func setConstraints() {
        
        topHorizontalStackView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.8)
        }
        
        newTaskTitleTextfield.snp.makeConstraints { make in
            make.top.equalTo(topHorizontalStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.height.equalTo(40)
        }
        
        newTaskImageLabel.snp.makeConstraints { make in
            make.top.equalTo(newTaskTitleTextfield.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
        }
        
        newTaskImageView.snp.makeConstraints { make in
            make.top.equalTo(newTaskImageLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.height.equalTo(UIScreen.main.bounds.height / 3)
        }
        
        imageAddButton.snp.makeConstraints { make in
            make.edges.equalTo(newTaskImageView)
        }
        
        imageAddView.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(imageAddButton).offset(-4)
            make.size.equalTo(44)
        }
        
        startDateStackView.snp.makeConstraints { make in
            make.top.equalTo(newTaskImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.height.equalTo(40)
        }
        
        endDateStackView.snp.makeConstraints { make in
            make.top.equalTo(startDateStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.height.equalTo(40)
        }
        
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(endDateStackView.snp.bottom).offset(16)
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.centerX.equalToSuperview()
        }
        
        successStackView.snp.makeConstraints { make in
            make.top.equalTo(successLabel.snp.bottom).offset(16)
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
    }
    
}
