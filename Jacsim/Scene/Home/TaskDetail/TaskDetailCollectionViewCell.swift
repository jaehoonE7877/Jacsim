//
//  TaskDetailCollectionViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

class TaskDetailCollectionViewCell: BaseCollectionViewCell {
    
    
    //MARK: UIImage, UILabel
    let dateLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
    }
    
    let certifiedImageView = UIImageView().then {
        makeShadow(view: $0)
        $0.backgroundColor = .lightGray
        $0.contentMode = .scaleToFill
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
        [dateLabel, certifiedImageView, certifiedMemo].forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        
        certifiedImageView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(6)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.74)
        }
        
        certifiedMemo.snp.makeConstraints { make in
            make.top.equalTo(certifiedImageView.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalToSuperview()
            
        }
    }
    
    func setData(image: UIImage){
        
    }
}
