//
//  PageView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/26.
//

import UIKit

class PageView: BaseView {
    
    //MARK: Property
    let mainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.image = UIImage(named: "jacsim")
    }
    
    let topLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Medium, size: 16)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "sdadasdadadasafafasfafafasfafafsaa"
    }
    
    let bottomLabel = UILabel().then {
        $0.font = UIFont.gothic(style: .Light, size: 16)
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.text = "sdadasdadadasafafasfafafasfafafsaa" 
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        [mainImageView, topLabel, bottomLabel].forEach { self.addSubview($0) }
    }
    
    override func setConstraints() {
        mainImageView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(8)
            make.width.equalTo(self).multipliedBy(0.88)
            make.centerX.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.6)
        }
        
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(16)
            make.width.equalTo(mainImageView)
            make.centerX.equalToSuperview()
        }
        
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(16)
            make.width.equalTo(mainImageView)
            make.centerX.equalToSuperview()
        }
    }
}
