//
//  DoneTaskTableViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

class DoneTableViewCell: BaseTableViewCell {
    
    
    let titleLabel = UILabel().then {
        $0.text = "작성 완료"
    }
    // 여기 다시 생각해보기(UIImage or UIButton)
    let rightImage = UIImage(systemName: "chevron.right")?.then{
        _ = $0.isSymbolImage
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Configure
    override func configure() {
       // [titleLabel, rightImage].forEach { contentView.addSubview($0) }
    }
    
    // MARK: Contraints
    override func setConstraints() {
        
    }
}
