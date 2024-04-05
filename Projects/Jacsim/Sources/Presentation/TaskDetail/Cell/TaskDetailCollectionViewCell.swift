//
//  TaskDetailCollectionViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

import DSKit

final class TaskDetailCollectionViewCell: UICollectionViewCell {
    //MARK: - Private Property
    let certifiedImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.contentMode = .scaleAspectFill
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = .labelAssistive
    }
    
    let dateLabel = UILabel().then {
        $0.font = .pretendardMedium(size: 12)
        $0.textColor = .labelNeutral
    }
    
    let certifiedMemo = UILabel().then {
        $0.font = .pretendardRegular(size: 12)
        $0.textColor = .labelStrong
        $0.numberOfLines = 2
    }
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setConstraints()
        self.layer.borderWidth = Constant.Design.borderWidth
        self.layer.cornerRadius = Constant.Design.cornerRadius
        self.layer.borderColor = .labelStrong
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    //MARK: - Override Method
    func configure() {
        [certifiedImageView, lineView, dateLabel, certifiedMemo].forEach { contentView.addSubview($0) }
    }
    
    func setConstraints() {
        
        certifiedImageView.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).offset(8)
            make.trailing.equalTo(contentView).offset(-8)
            make.height.equalTo(contentView).multipliedBy(0.6)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(certifiedImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalTo(certifiedImageView)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(certifiedImageView)
        }
        
        certifiedMemo.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.width.equalTo(certifiedImageView)
        }
    }
    //MARK: - Public Method
    func setData(jacsim: UserJacsim, image: UIImage, indexPath: Int) {
        dateLabel.text = DateFormatType.toString(jacsim.jacsimDayArray[indexPath], to: .fullWithoutYear)
        certifiedMemo.text = jacsim.memoList[indexPath].memo
        certifiedImageView.image = image
    }
}
