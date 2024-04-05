//
//  TaskDetailView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/18.
//

import UIKit

import DSKit

class TaskDetailView: BaseView {
    
    //MARK: UIImage, UILabel, [UILabel, UILabel], [UILabel, UILabel], UICollectionView
    let mainImage = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.contentMode = .scaleAspectFill
    }
    
    let startLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 14)
        $0.textColor = DSKitAsset.Colors.text.color
        $0.text = "시작일"
    }
    
    let startDateLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 14)
        $0.textColor = DSKitAsset.Colors.text.color
        $0.textAlignment = .right
    }
    
    let endLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 14)
        $0.textColor = DSKitAsset.Colors.text.color
        $0.text = "종료일"
    }
    
    let endDateLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 14)
        $0.textColor = DSKitAsset.Colors.text.color
        $0.textAlignment = .right
    }
    
    let alarmLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 14)
        $0.textColor = DSKitAsset.Colors.text.color
        $0.text = "알람 시간"
    }
    
    let alarmTimeLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 14)
        $0.textColor = DSKitAsset.Colors.text.color
        $0.textAlignment = .right
    }
    
    let successLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.gothic(style: .Medium, size: 18)
        $0.textColor = DSKitAsset.Colors.text.color
    }
    
    let lineView = UIView().then {
        $0.backgroundColor = DSKitAsset.Colors.text.color
    }
    
    let certifyLabel = UILabel().then {
        $0.text = "인증 사진"
        $0.font = UIFont.gothic(style: .Medium, size: 18)
        $0.textColor = DSKitAsset.Colors.text.color
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 2.5
        let spacing: CGFloat = 16
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width, height: width * 1.28)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .backgroundNormal
        return collectionView
    }()
    
    lazy var startStackView = UIStackView(arrangedSubviews: [startLabel, startDateLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
        
    }
    
    lazy var endStackView = UIStackView(arrangedSubviews: [endLabel, endDateLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
        
    }
    
    lazy var alarmStackView = UIStackView(arrangedSubviews: [alarmLabel, alarmTimeLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        [mainImage, startStackView, endStackView, alarmStackView, successLabel, lineView, certifyLabel, collectionView].forEach { self.addSubview($0) }
    }
    
    override func setConstraints() {
        
        mainImage.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(8)
            make.width.equalTo(self).multipliedBy(0.88)
            make.centerX.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.35)
        }
        
        startStackView.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(mainImage)
        }
        
        endStackView.snp.makeConstraints { make in
            make.top.equalTo(startStackView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(mainImage)
        }
        
        alarmStackView.snp.makeConstraints { make in
            make.top.equalTo(endStackView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(mainImage)
        }
        
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(alarmStackView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(successLabel.snp.bottom).offset(6)
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
            make.width.equalTo(mainImage)
        }
        
        certifyLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(12)
            make.leading.equalTo(mainImage.snp.leading)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(certifyLabel.snp.bottom)
            make.leading.equalTo(mainImage.snp.leading)
            make.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
        }
        
        
    }
    
    
}
