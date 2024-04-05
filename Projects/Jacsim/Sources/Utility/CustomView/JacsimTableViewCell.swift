//
//  HomeTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

import DSKit

final class JacsimTableViewCell: BaseTableViewCell {
    
    let jacsimContentView = UIView().then {
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.layer.masksToBounds = true
        $0.clipsToBounds = true
        $0.backgroundColor = .primaryNormal
    }
    
    let titleLabel = UILabel().then {
        $0.attributedText = " ".heading4(color: .labelStrong)
    }
    
    let alarmImageView = UIImageView().then {
        $0.tintColor = DSKitAsset.Colors.text.color
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setCellStyle(title: String, alarm: Date?) {
        titleLabel.updateAttString(title)
        alarmImageView.image = alarm == nil
        ? nil
        : DSKitAsset.Assets.bellFill.image.withRenderingMode(.alwaysTemplate)
    }
    
}

extension JacsimTableViewCell {
    private func setView() {
        contentView.backgroundColor = .backgroundNormal
        contentView.addSubview(jacsimContentView)
        
        jacsimContentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview()
        }
        
        jacsimContentView.addSubviews([titleLabel, alarmImageView])
        
        alarmImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(12)
            make.verticalEdges.equalToSuperview().inset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalTo(alarmImageView)
        }
    }
}
