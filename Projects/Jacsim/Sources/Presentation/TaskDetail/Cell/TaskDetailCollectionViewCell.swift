//
//  TaskDetailCollectionViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class TaskDetailCollectionViewCell: BaseCollectionViewCell {
    //MARK: - Private Property
   let certifiedImageView = UIImageView().then {
        $0.backgroundColor = Constant.BaseColor.placeholderColor
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = Constant.BaseColor.textColor
    }
    
    let dateLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 12)
        $0.textColor = Constant.BaseColor.textColor
    }
    
    let certifiedMemo = UILabel().then {
        $0.font = UIFont.gothic(style: .Light, size: 12)
        $0.textColor = Constant.BaseColor.textColor
        $0.numberOfLines = 2
    }
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = Constant.Design.borderWidth
        self.layer.cornerRadius = Constant.Design.cornerRadius
        self.layer.borderColor = Constant.BaseColor.textColor?.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    //MARK: - Override Method
    override func configure() {
        [certifiedImageView, lineView, dateLabel, certifiedMemo].forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        
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
