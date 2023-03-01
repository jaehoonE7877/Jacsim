//
//  HomeTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class JacsimTableViewCell: BaseTableViewCell {
    
    let jacsimContentView = UIView().then {
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.layer.masksToBounds = true
        //$0.clipsToBounds = true
        $0.backgroundColor = Constant.BaseColor.buttonColor
    }
    
    let titleLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Light, size: 18)
        $0.textAlignment = .left
    }
    
    lazy var alarmImageView = UIImageView().then {
        $0.isHidden = true
        $0.image = UIImage(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18))
        $0.tintColor = Constant.BaseColor.textColor
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        contentView.backgroundColor = Constant.BaseColor.backgroundColor
        contentView.addSubview(jacsimContentView)
        [titleLabel, alarmImageView].forEach { jacsimContentView.addSubview($0) }
        
    }
    
    override func setConstraints() {
        
        jacsimContentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(contentView)
            make.height.equalTo(contentView).multipliedBy(0.72)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(jacsimContentView.snp.leading).offset(12)
            make.width.equalTo(jacsimContentView).multipliedBy(0.84)
            make.centerY.equalTo(jacsimContentView.snp.centerY)
        }
        
        alarmImageView.snp.makeConstraints { make in
            make.trailing.equalTo(jacsimContentView.snp.trailing).offset(-12)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
    }
    
    func setCellStyle(title: String, alarm: Date?) {
        self.selectionStyle = .none
        self.titleLabel.text = title
        if alarm != nil {
            self.alarmImageView.isHidden = false
        } else {
            self.alarmImageView.isHidden = true
        }
    }
    
}
