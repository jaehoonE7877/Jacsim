//
//  TaskUpdateView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/20.
//

import UIKit

final class TaskUpdateView: BaseView {
    
    //MARK: Property
    
    let certifyImageView = UIImageView().then {
        makeShadow(view: $0)
        $0.backgroundColor = .lightGray
    }
    
    let imageAddButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36)), for: .normal)
        $0.showsMenuAsPrimaryAction = true
        $0.tintColor = Constant.BaseColor.buttonColor
    }
    
    let memoLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.text = "한 줄 메모"
    }
    
    let memoCountLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "0/20"
        $0.textAlignment = .right
    }
    
    let memoTextfield = UITextField().then {
        makeShadow(view: $0)
        $0.backgroundColor = .lightGray
        $0.placeholder = "한 줄 메모를 입력해주세요"
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14)
    }
    
    let certifyButton = UIButton().then {
        makeShadow(view: $0)
        $0.setTitle("인증하겠습니다!", for: .normal)
        $0.tintColor = .black
        $0.backgroundColor = Constant.BaseColor.buttonColor
    }
    
    lazy var memoStackView = UIStackView(arrangedSubviews: [memoLabel, memoCountLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        
        memoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        memoCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        [certifyImageView, imageAddButton, memoStackView, memoTextfield, certifyButton].forEach { self.addSubview($0)}
    }
    
    override func setConstraints() {
        
        certifyImageView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.8)
            make.height.equalTo(UIScreen.main.bounds.height / 2.4)
        }
        
        imageAddButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(certifyImageView).offset(-4)
            make.size.equalTo(44)
        }
        
        memoStackView.snp.makeConstraints { make in
            make.top.equalTo(certifyImageView.snp.bottom).offset(20)
            make.width.equalTo(certifyImageView.snp.width)
            make.centerX.equalToSuperview()
        }
        
        memoTextfield.snp.makeConstraints { make in
            make.top.equalTo(memoStackView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(certifyImageView.snp.width)
            make.height.equalTo(40)
        }
        
        certifyButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextfield.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(certifyImageView.snp.width)
            make.height.equalTo(44)
        }
    }
    
}
