//
//  HeaderView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

final class HeaderView: UITableViewHeaderFooterView {
    
    let headerLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
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
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.snp.leading)
        }
    }
    
}
