//
//  AlarmView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/27.
//

import UIKit

import DSKit

final class AlarmView: BaseView {
    
    //MARK: Property (xmark, 확인, DatePicker)
    let view = UIView().then {
        $0.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
    }
    
    let backgroundView = UIView().then {
        $0.backgroundColor = DSKitAsset.Colors.background.color
        $0.layer.cornerRadius = Constant.Design.cornerRadius
    }
    
    let xButton = UIButton().then {
        $0.setImage(UIImage.xmark, for: .normal)
        $0.tintColor = DSKitAsset.Colors.text.color
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(DSKitAsset.Colors.text.color, for: .normal)
    }
    
    lazy var datePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .wheels
        $0.datePickerMode = .time
        
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        self.addSubview(view)
        view.addSubview(backgroundView)
        [xButton, saveButton, datePicker].forEach { backgroundView.addSubview($0) }
    }
    
    override func setConstraints() {
        
        view.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
            make.width.equalTo(view.snp.width).multipliedBy(0.8)
            make.height.equalTo(backgroundView.snp.width)
        }
        
        xButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(backgroundView.snp.leading).offset(12)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(backgroundView.snp.trailing).offset(-12)
            make.centerY.equalTo(xButton.snp.centerY)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(xButton.snp.bottom)
            make.center.equalToSuperview()
        }
    }
    
}
