//
//  TaskDetailView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/18.
//

import UIKit

class TaskDetailView: BaseView {
    
    //MARK: UIImage, UILabel, [UILabel, UILabel], [UILabel, UILabel], UICollectionView
    let mainImage = UIImageView().then {
        $0.backgroundColor = Constant.BaseColor.placeholderColor
        $0.contentMode = .scaleToFill
    }
    
    let startLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 16)
        $0.textColor = Constant.BaseColor.textColor
        $0.text = "시작일"
    }
    
    let startDateLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 16)
        $0.textColor = Constant.BaseColor.textColor
        $0.textAlignment = .right
    }
    
    let endLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 16)
        $0.textColor = Constant.BaseColor.textColor
        $0.text = "종료일"
    }
    
    let endDateLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 16)
        $0.textColor = Constant.BaseColor.textColor
        $0.textAlignment = .right
    }
    
    let successLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.gothic(style: .Medium, size: 20)
        $0.textColor = Constant.BaseColor.textColor
    }
    
    let lineView = UIView().then {
        $0.backgroundColor = Constant.BaseColor.textColor
    }
    
    let certifyLabel = UILabel().then {
        $0.text = "인증 사진"
        $0.font = UIFont.gothic(style: .Medium, size: 20)
        $0.textColor = Constant.BaseColor.textColor
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 2.5
        let spacing: CGFloat = 16
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width, height: width * 1.36)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        [mainImage, startStackView, endStackView, successLabel, lineView, certifyLabel, collectionView].forEach { self.addSubview($0) }
    }
    
    override func setConstraints() {
        
        mainImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(self).multipliedBy(0.35)
        }
        
        startStackView.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.88)
        }
        
        endStackView.snp.makeConstraints { make in
            make.top.equalTo(startStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(startStackView)
        }
        
        successLabel.snp.makeConstraints { make in
            make.top.equalTo(endStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(startStackView)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(successLabel.snp.bottom).offset(12)
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
            make.width.equalTo(startStackView)
        }
        
        certifyLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(12)
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(certifyLabel.snp.bottom)//.offset(8)
            make.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
        }
        
        
    }
    
    
}
