//
//  HeaderView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

import DSKit

import RxSwift

final class JacsimHeaderView: UITableViewHeaderFooterView {
        
    let headerLabel = UILabel().then {
        $0.attributedText = "작심한 일".heading3(color: .labelNormal)
    }

    let infoButton = UIButton().then {
        $0.setImage(DSKitAsset.Assets.circleQuestion.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .labelNormal
    }
    
    let sortButton = UIButton().then {
        $0.setTitle("오늘의 작심", for: .normal)
        $0.setTitleColor(.labelNormal, for: .normal)
        $0.titleLabel?.font = .pretendardMedium(size: 16)
    }
    
    private(set) var disposeBag: DisposeBag = .init()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
         fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
    }
    
    private func configure() {
        contentView.backgroundColor = .backgroundNormal
        contentView.addSubviews([headerLabel, infoButton, sortButton])
    }
    
    private func setConstraints() {

        infoButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        sortButton.snp.makeConstraints { make in
            make.centerY.equalTo(infoButton)
            make.trailing.equalTo(infoButton.snp.leading).offset(-8)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(infoButton)
        }
    }
}
