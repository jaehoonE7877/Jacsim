//
//  ImageSearchView.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/16.
//

import UIKit

class ImageSearchView: BaseView {
    
    lazy var searchBar = UISearchBar().then {
        $0.backgroundColor = Constant.BaseColor.placeholderColor
        
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width * 0.88 ) / 3
        
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure() {
        [searchBar, collectionView].forEach { self.addSubview($0) }
    }
    
    override func setConstraints() {
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(self).multipliedBy(0.88)
            make.height.equalTo(56)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.width.equalTo(searchBar)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}

