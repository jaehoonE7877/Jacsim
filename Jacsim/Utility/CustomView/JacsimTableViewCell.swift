//
//  HomeTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class JacsimTableViewCell: BaseTableViewCell {
    
    let jacsimContentView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.clipsToBounds = true
        $0.backgroundColor = Constant.BaseColor.buttonColor
    }
    
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20)
        $0.textAlignment = .left
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        contentView.addSubview(jacsimContentView)
        jacsimContentView.addSubview(titleLabel)
    }
    
    override func setConstraints() {
        
        jacsimContentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(contentView).multipliedBy(0.95)
            make.height.equalTo(contentView).multipliedBy(0.72)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(jacsimContentView.snp.leading).offset(20)
            make.centerY.equalToSuperview()
        }
    }
    
}
