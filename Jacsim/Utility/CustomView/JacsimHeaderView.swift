//
//  HeaderView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

class JacsimHeaderView: UITableViewHeaderFooterView {
    
    let headerLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 22)
        $0.textColor = .black
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
        self.addSubview(headerLabel)
    }
    
    private func setConstraints() {
        headerLabel.snp.makeConstraints { make in 
            make.top.equalTo(self.snp.top).offset(8)
            make.leading.equalTo(self.snp.leading).offset(12)
        }
    }
    
}
