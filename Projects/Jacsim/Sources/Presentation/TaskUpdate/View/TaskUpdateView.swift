//
//  TaskUpdateView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/20.
//

import UIKit

import DSKit

final class TaskUpdateView: UIView {
    
    //MARK: Property
    
    let certifyImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.contentMode = .scaleAspectFill
    }
    
    let imageAddButton = UIButton(type: .system).then {
        $0.showsMenuAsPrimaryAction = true
    }
    
    private let imageAddView: UIImageView = .init().then {
        $0.image = DSKitAsset.Assets.circlePlus.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .primaryNormal
        $0.isUserInteractionEnabled = false
    }
    
    let memoLabel = UILabel().then {
        $0.font = .pretendardBold(size: 20)
        $0.textColor = .labelStrong
        $0.text = "한 줄 메모"
    }
    
    let memoCountLabel = UILabel().then {
        $0.font = .pretendardMedium(size: 14)
        $0.textColor = .labelNeutral
        $0.text = "0/20"
        $0.textAlignment = .right
    }
    
    let memoTextfield = UITextField().then {
        $0.backgroundColor = .clear
        $0.setPlaceholder(text: "한 줄 메모를 입력해주세요")
        $0.textAlignment = .center
        $0.textColor = .labelNeutral
        $0.font = .pretendardRegular(size: 14)
    }
    
    let certifyButton = UIButton().then {
        $0.setTitle("인증하겠습니다!", for: .normal)
        $0.setTitleColor(.labelStrong, for: .normal)
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.backgroundColor = .primaryHeavy
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
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure() {
        [certifyImageView, imageAddButton, memoStackView, memoTextfield, certifyButton].forEach { self.addSubview($0)}
        imageAddButton.addSubview(imageAddView)
    }
    
    func setConstraints() {
        
        certifyImageView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.88)
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
        
        imageAddView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
