//
//  AllTaskJacsimHeaderView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 4/4/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

import DSKit

final class AllTaskJacsimHeaderView: UITableViewHeaderFooterView {
    
    let foldButton = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    let headerLabel = UILabel().then {
        $0.attributedText = " ".heading3(color: .labelNormal)
        $0.isUserInteractionEnabled = false
    }

    let foldImage = UIImageView().then {
        $0.tintColor = .labelNeutral
        $0.isUserInteractionEnabled = false
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
        contentView.backgroundColor = .backgroundNormal
        contentView.addSubview(foldButton)
        foldButton.addSubviews([foldImage, headerLabel])
    }
    
    private func setConstraints() {
        
        foldButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        foldImage.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(12)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(foldImage)
        }
    }
}
