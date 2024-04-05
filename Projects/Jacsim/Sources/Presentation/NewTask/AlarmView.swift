//
//  AlarmView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/27.
//

import UIKit

import DSKit

final class AlarmView: UIView {
    
    //MARK: Property (xmark, 확인, DatePicker)
    let view = UIView().then {
        $0.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
    }
    
    let backgroundView = UIView().then {
        $0.backgroundColor = .backgroundNormal
        $0.layer.cornerRadius = Constant.Design.cornerRadius
    }
    
    let xButton = UIButton().then {
        let image = DSKitAsset.Assets.close.image.withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.tintColor = .labelNormal
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(.labelNormal, for: .normal)
    }
    
    lazy var datePicker = UIDatePicker().then {
        $0.preferredDatePickerStyle = .wheels
        $0.datePickerMode = .time
        
        $0.locale = .KR
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setConstraints()
        self.view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure() {
        self.addSubview(view)
        view.addSubview(backgroundView)
        [xButton, saveButton, datePicker].forEach { backgroundView.addSubview($0) }
    }
    
    func setConstraints() {
        
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
