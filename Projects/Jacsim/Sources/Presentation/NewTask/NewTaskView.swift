//
//  NewTaskView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

import DSKit

final class NewTaskView: UIView {
    
    // MARK: Property
    let newTaskTitleLabel = UILabel().then {
        $0.font = .pretendardSemiBold(size: 20)
        $0.textColor = .labelStrong
        $0.text = "작심의 이름을 정해주세요"
    }
    
    let titleCountLabel = UILabel().then {
        $0.font = .pretendardRegular(size: 14)
        $0.textColor = .labelNormal
        $0.textAlignment = .right
        $0.text = "0/20"
    }
    
    let newTaskTitleTextfield = LimitTextField(limitCount: 20).then {
        $0.setPlaceholder(text: "예시 - 아침에 일어나서 물 마시기")
        $0.textAlignment = .center
        $0.textColor = .labelNeutral
        $0.font = .pretendardRegular(size: 16)
    }
    
    let newTaskImageLabel = UILabel().then {
        $0.font = .pretendardSemiBold(size: 20)
        $0.textColor = .labelStrong
        $0.text = "작심의 대표 이미지를 정해주세요"
    }
    
    let newTaskImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.contentMode = .scaleAspectFill
    }
    
    let imageAddButton = UIButton(type: .system).then {
        $0.showsMenuAsPrimaryAction = true
    }
    
    let imageAddView = UIImageView().then {
        $0.image = DSKitAsset.Assets.circlePlus.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .primaryNormal
    }
    
    let dateLabel = UILabel().then {
        $0.font = .pretendardSemiBold(size: 20)
        $0.textColor = DSKitAsset.Colors.text.color
        $0.text = "시작일과 종료일을 정해주세요"
    }
    
    let startDateTextField = UITextField().then {
        $0.setPlaceholder(text: "시작일")
        $0.textColor = .labelNeutral
        $0.font = .pretendardRegular(size: 16)
        $0.textAlignment = .center
        $0.layer.cornerRadius = Constant.Design.cornerRadius
    }
    
    let termLabel = UILabel().then {
        $0.font = .pretendardMedium(size: 16)
        $0.textColor = .labelNeutral
        $0.text = "~"
    }
    
    let endDateTextField = UITextField().then {
        $0.textColor = .labelNeutral
        $0.font = .pretendardRegular(size: 16)
        $0.textAlignment = .center
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.setPlaceholder(text: "종료일")
    }
    
    let successLabel = UILabel().then {
        $0.text = "성공 기준 횟수를 정해주세요"
        $0.font = .pretendardSemiBold(size: 20)
        $0.textColor = .labelStrong
    }
    
    let successTextField = UITextField().then {
        $0.textAlignment = .center
        $0.keyboardType = .numberPad
        $0.addDoneButtonOnKeyboard()
        $0.text = "1"
        $0.textColor = .labelNeutral
        $0.font = .pretendardMedium(size: 16)
    }
    let successCountLabel = UILabel().then {
        $0.font = .pretendardMedium(size: 16)
        $0.textColor = .labelStrong
        $0.text = "회"
    }
    
    let alarmLabel = UILabel().then {
        $0.font = .pretendardSemiBold(size: 20)
        $0.textColor = .labelStrong
        $0.text = "알람을 설정해주세요"
    }

    let alarmSwitch = UISwitch().then {
        $0.isOn = false
    }
    
    lazy var alarmTimeLabel = UILabel().then {
        $0.font = .pretendardMedium(size: 16)
        $0.textColor = .positive
        $0.textAlignment = .left
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
    
    lazy var datePickStackView = UIStackView(arrangedSubviews: [startDateTextField, endDateTextField]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 12
        
    }
   
    
    lazy var successStackView = UIStackView(arrangedSubviews: [successTextField, successCountLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
        
        successTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(52)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        successCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
        }
    }
    
    lazy var alarmStackView = UIStackView(arrangedSubviews: [alarmLabel, alarmSwitch]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
        
        alarmLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        alarmSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(alarmSwitch.snp.width).multipliedBy(0.8)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure() {
        [topHorizontalStackView, newTaskTitleTextfield, newTaskImageLabel, newTaskImageView, imageAddButton, imageAddView, dateLabel, datePickStackView, termLabel, successLabel, successStackView, alarmStackView, alarmTimeLabel].forEach{ self.addSubview($0) }
    }
    //MARK: Constraints 
    func setConstraints() {
        
        topHorizontalStackView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.88)
        }
        
        newTaskTitleTextfield.snp.makeConstraints { make in
            make.top.equalTo(topHorizontalStackView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.height.equalTo(40)
        }
        
        newTaskImageLabel.snp.makeConstraints { make in
            make.top.equalTo(newTaskTitleTextfield.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
        }
        
        newTaskImageView.snp.makeConstraints { make in
            make.top.equalTo(newTaskImageLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.height.equalTo(UIScreen.main.bounds.height / 3)
        }
        
        imageAddView.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(newTaskImageView).offset(-4)
            make.size.equalTo(44)
        }
        
        imageAddButton.snp.makeConstraints { make in
            make.edges.equalTo(imageAddView)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(newTaskImageView.snp.bottom).offset(12)
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.centerX.equalToSuperview()
        }
        
        datePickStackView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.width.equalTo(topHorizontalStackView.snp.width)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        termLabel.snp.makeConstraints { make in
            make.center.equalTo(datePickStackView)
        }
        
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(datePickStackView.snp.bottom).offset(16)
            make.leading.equalTo(datePickStackView.snp.leading)
        }
        
        successStackView.snp.makeConstraints { make in
            make.top.equalTo(successLabel)
            make.leading.equalTo(successLabel.snp.trailing).offset(12)
            make.trailing.equalTo(datePickStackView.snp.trailing)
            make.centerY.equalTo(successLabel)
        }
        
        alarmStackView.snp.makeConstraints { make in
            make.top.equalTo(successStackView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(topHorizontalStackView.snp.width)
        }
        
        alarmTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(alarmStackView.snp.bottom)
            make.leading.equalTo(alarmStackView.snp.leading)
        }
        
    }
    
}
