//
//  SettingTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/22.
//

import UIKit

import Core
import DSKit

final class SettingTableViewCell: UITableViewCell {
    
    //MARK: property
    let titleLabel = UILabel().then {
        $0.font = .pretendardMedium(size: 16)
    }
    
    lazy var pushImage = UIImageView().then {
        $0.image = DSKitAsset.Assets.chevronRight.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .darkGray
    }
    
    lazy var versionLabel = UILabel().then {
        $0.text = Bundle.mainAppVersion
        $0.font = .pretendardSemiBold(size: 14)
    }
    
    //MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: Configure
    func configure() {
        contentView.addSubviews([titleLabel, pushImage, versionLabel])
    }
    
    //MARK: SetConstraints
    func setConstraints() {
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
