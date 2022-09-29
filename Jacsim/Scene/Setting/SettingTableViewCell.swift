//
//  SettingTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/22.
//

import UIKit

class SettingTableViewCell: BaseTableViewCell {
    
    //MARK: property
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
    }
    
    lazy var pushImage = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        $0.tintColor = .darkGray
    }
    
    lazy var versionLabel = UILabel().then {
        $0.text = "1.0.11"
        $0.font = .systemFont(ofSize: 14)
    }
    
    //MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: Configure
    override func configure() {
        [titleLabel, pushImage, versionLabel].forEach { contentView.addSubview($0) }
    }
    
    //MARK: SetConstraints
    override func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(contentView)
        }
        
        pushImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(contentView)
        }
    }
    
}
