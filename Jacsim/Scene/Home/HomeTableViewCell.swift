//
//  HomeTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

class HomeTableViewCell: BaseTableViewCell {
    
    //shadowview, image, label
    
    let shadowView = UIView().then {
        makeShadow(view: $0)
        $0.backgroundColor = .clear
    }
    
    let jacsimContentView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.clipsToBounds = true
        $0.backgroundColor = Constant.BaseColor.customCellColor
    }
    
    let isDoneImage = UIImageView().then {
        $0.image = UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 10.0)))
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFill
    }
    
    let titleLabel = UILabel().then {
        $0.text = "물 마시기"
        $0.font = .systemFont(ofSize: 20)
        $0.textAlignment = .left
    }
    
    lazy var horizontalStackView = UIStackView(arrangedSubviews: [isDoneImage, titleLabel]).then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.spacing = 12
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        contentView.addSubview(shadowView)
        shadowView.addSubview(jacsimContentView)
        jacsimContentView.addSubview(horizontalStackView)
    }
    
    override func setConstraints() {
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(12)
        }
        
        jacsimContentView.snp.makeConstraints { make in
            make.edges.equalTo(shadowView)
        }
        
        horizontalStackView.snp.makeConstraints { make in
            make.edges.equalTo(jacsimContentView.snp.edges).inset(8)
        }
    }
    
    func setData(){
        
    }
}
