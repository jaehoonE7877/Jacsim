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
        $0.backgroundColor = .lightGray
        $0.contentMode = .scaleToFill
    }
    
    let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.text = "작심 제목"
    }
    
    let startLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.text = "시작일"
    }
    
    let startDateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    
    let endLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.text = "종료일"
    }
    
    let endDateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .right
    }
    
    let lineView = UIView().then {
        $0.backgroundColor = .black
    }
    
    let certifyLabel = UILabel().then {
        $0.text = "인증 사진"
        $0.font = .boldSystemFont(ofSize: 18)
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width / 2.5
        let spacing: CGFloat = 16
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width, height: width * 1.2)
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
        [mainImage, titleLabel, startStackView, endStackView, lineView, certifyLabel, collectionView].forEach { self.addSubview($0) }
    }
    
    override func setConstraints() {
        
        mainImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(self).multipliedBy(0.35)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom).offset(16)
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(16)
        }
        
        startStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.88)
        }
        
        endStackView.snp.makeConstraints { make in
            make.top.equalTo(startStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(startStackView)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(endStackView.snp.bottom).offset(12)
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
            make.width.equalTo(startStackView.snp.width)
        }
        
        certifyLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(12)
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(certifyLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
            
        }
        
        
    }
    
    
}
