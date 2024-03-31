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
        $0.backgroundColor = DSKitAsset.Colors.button.color
    }
    
    let titleLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Light, size: 18)
        $0.textAlignment = .left
    }
    
    lazy var alarmImageView = UIImageView().then {
        $0.isHidden = true
        $0.image = UIImage(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18))
        $0.tintColor = DSKitAsset.Colors.text.color
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setView()
    }

    required init?(coder: NSCoder) {
        fatalError()
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

extension JacsimTableViewCell {
    private func setView() {
        contentView.backgroundColor = DSKitAsset.Colors.background.color
        contentView.addSubview(jacsimContentView)
        jacsimContentView.addSubviews([titleLabel, alarmImageView])
        
        jacsimContentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        alarmImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
}
