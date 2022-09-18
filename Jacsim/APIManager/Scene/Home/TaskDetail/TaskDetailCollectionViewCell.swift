//
//  TaskDetailCollectionViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

class TaskDetailCollectionViewCell: BaseCollectionViewCell {
    
    
    //MARK: UIImage, UILabel
    let certifiedImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.contentMode = .scaleAspectFill
    }
    
    let certifiedMemo = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        [certifiedImageView, certifiedMemo].forEach { self.addSubview($0) }
    }
    
    override func setConstraints() {
        certifiedImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.84)
        }
        
        certifiedMemo.snp.makeConstraints { make in
            make.top.equalTo(certifiedImageView.snp.bottom).offset(8)
            make.leading.bottom.equalToSuperview()
        }
    }
    
    func setData(image: UIImage){
        
    }
}
