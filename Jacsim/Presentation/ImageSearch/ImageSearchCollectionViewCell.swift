//
//  ImageSearchCollectionViewCell.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/12.
//

import UIKit

class ImageSearchCollectionViewCell: BaseCollectionViewCell {
    
    // MARK: UIImageView
    let imageView = UIImageView().then {
        $0.backgroundColor = Constant.BaseColor.placeholderColor
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func configure() {
        self.addSubview(imageView)
    }
    
    override func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
//    func setData(imageURL: URL?) {
//        imageView.kf.setImage(with: imageURL)
//    }
}
