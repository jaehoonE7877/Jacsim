//
//  HeaderView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class JacsimHeaderView: UITableViewHeaderFooterView {
    
    lazy var foldButton = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    let headerLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 24)
        $0.textColor = Constant.BaseColor.textColor
    }

    lazy var foldImage = UIImageView().then {
        $0.tintColor = Constant.BaseColor.placeholderColor
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
         fatalError()
    }
    
    private func configure() {
        self.addSubview(foldButton)
        [headerLabel, foldImage, foldButton].forEach { self.addSubview($0)}
        
    }
    
    private func setConstraints() {
        
        headerLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(12)
            make.centerY.equalToSuperview()
        }

        foldImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.snp.trailing).offset(-12)
        }
        
        foldButton.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
}
