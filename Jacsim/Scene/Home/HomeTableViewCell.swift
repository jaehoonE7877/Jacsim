//
//  HomeTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class HomeTableViewCell: BaseTableViewCell {
    
    //shadowview, image, label
    
    let shadowView = UIView().then {
        makeShadow(view: $0)
        $0.backgroundColor = .clear
    }
    
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
        contentView.addSubview(shadowView)
        shadowView.addSubview(jacsimContentView)
        jacsimContentView.addSubview(titleLabel)
    }
    
    override func setConstraints() {
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(12)
        }
        
        jacsimContentView.snp.makeConstraints { make in
            make.edges.equalTo(shadowView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(jacsimContentView.snp.leading).offset(20)
            make.centerY.equalToSuperview()
        }
    }
    
}
