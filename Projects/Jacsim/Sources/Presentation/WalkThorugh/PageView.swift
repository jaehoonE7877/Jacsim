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
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = Constant.Design.cornerRadius
        $0.image = UIImage(named: "jacsim")
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        self.addSubview(mainImageView)
    }
    
    override func setConstraints() {
        mainImageView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(40)
            make.width.equalTo(self).multipliedBy(0.92)
            make.centerX.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.72)
        }
        
        
    }
}
